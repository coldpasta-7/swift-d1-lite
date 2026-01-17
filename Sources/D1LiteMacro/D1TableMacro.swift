public import SwiftSyntax
public import SwiftSyntaxMacros

/// `@D1Table` を展開して D1 テーブルの補助メンバーを生成します.
public struct D1TableMacro: MemberMacro, ExtensionMacro {
  /// マクロをメンバー宣言に展開します.
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard let structDecl = declaration.as(StructDeclSyntax.self) else {
      return []
    }

    let schema = parseSchemaArgument(from: node)
    let columns = parseColumns(from: structDecl)

    guard !columns.isEmpty else {
      return []
    }

    var decls: [DeclSyntax] = []
    decls.append(DeclSyntax(stringLiteral: buildInitializer(columns: columns)))
    decls.append(DeclSyntax(stringLiteral: buildSchema(schema: schema)))
    decls.append(DeclSyntax(stringLiteral: buildColumnsList(columns: columns)))
    decls.append(contentsOf: columns.map { DeclSyntax(stringLiteral: buildColumnDeclaration(column: $0)) })
    decls.append(DeclSyntax(stringLiteral: buildAllColumnNames(columns: columns)))
    decls.append(DeclSyntax(stringLiteral: buildAllD1Values(columns: columns)))
    decls.append(DeclSyntax(stringLiteral: buildD1Format(columns: columns)))
    decls.append(DeclSyntax(stringLiteral: buildD1ColumnName(columns: columns)))
    decls.append(DeclSyntax(stringLiteral: buildDecode(columns: columns)))
    return decls
  }

  /// D1Table 準拠の拡張を追加します.
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {
    guard let structDecl = declaration.as(StructDeclSyntax.self) else {
      return []
    }
    if hasD1TableConformance(structDecl.inheritanceClause) {
      return []
    }
    let extensionDecl = DeclSyntax(stringLiteral: "extension \(type.trimmedDescription): D1Lite.D1Table {}")
    guard let typedExtension = extensionDecl.as(ExtensionDeclSyntax.self) else {
      return []
    }
    return [typedExtension]
  }
}

/// モデルのカラムを示すマーカーマクロです.
public struct D1ColumnMacro: PeerMacro {
  /// ピア宣言を生成せずにマクロを展開します.
  public static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    []
  }
}

fileprivate struct ColumnInfo {
  var propertyName: String
  var columnName: String
  var typeName: String
  var baseTypeName: String
  var isOptional: Bool
  var formatStyle: String
  var formatStyleTypeName: String?
}

fileprivate func parseSchemaArgument(from node: AttributeSyntax) -> String {
  guard let argumentList = node.arguments?.as(LabeledExprListSyntax.self) else {
    return ""
  }
  for argument in argumentList {
    let label = argument.label?.text ?? ""
    if label == "schema", let value = stringLiteralValue(argument.expression) {
      return value
    }
  }
  return ""
}

fileprivate func parseColumns(from structDecl: StructDeclSyntax) -> [ColumnInfo] {
  var columns: [ColumnInfo] = []
  for member in structDecl.memberBlock.members {
    guard let varDecl = member.decl.as(VariableDeclSyntax.self) else {
      continue
    }
    guard let columnAttribute = columnAttribute(in: varDecl.attributes) else {
      continue
    }
    for binding in varDecl.bindings {
      guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self),
        let typeAnnotation = binding.typeAnnotation
      else {
        continue
      }
      let propertyName = pattern.identifier.text
      let typeSyntax = typeAnnotation.type
      let (typeName, baseTypeName, isOptional) = typeInfo(typeSyntax)
      let (columnName, formatStyleOverride, formatStyleTypeName) = parseColumnArguments(
        columnAttribute,
        defaultName: propertyName
      )
      let formatStyleInfo = formatStyleExpression(
        typeName: typeName,
        baseTypeName: baseTypeName,
        isOptional: isOptional,
        override: formatStyleOverride,
        overrideTypeName: formatStyleTypeName
      )
      columns.append(
        ColumnInfo(
          propertyName: propertyName,
          columnName: columnName,
          typeName: typeName,
          baseTypeName: baseTypeName,
          isOptional: isOptional,
          formatStyle: formatStyleInfo.expression,
          formatStyleTypeName: formatStyleInfo.typeName
        )
      )
    }
  }
  return columns
}

fileprivate func columnAttribute(in attributes: AttributeListSyntax?) -> AttributeSyntax? {
  guard let attributes else {
    return nil
  }
  for attribute in attributes {
    guard let attribute = attribute.as(AttributeSyntax.self) else {
      continue
    }
    if attribute.attributeName.trimmedDescription == "D1Column" {
      return attribute
    }
  }
  return nil
}

fileprivate func parseColumnArguments(
  _ attribute: AttributeSyntax,
  defaultName: String
) -> (name: String, formatStyleExpression: String?, formatStyleTypeName: String?) {
  guard let argumentList = attribute.arguments?.as(LabeledExprListSyntax.self) else {
    return (defaultName, nil, nil)
  }
  var name = defaultName
  var formatStyleExpression: String?
  var formatStyleTypeName: String?
  for argument in argumentList {
    let label = argument.label?.text ?? ""
    if label == "name", let value = stringLiteralValue(argument.expression) {
      name = value
    } else if label == "formatStyle" {
      formatStyleExpression = argument.expression.trimmedDescription
      formatStyleTypeName = inferFormatStyleTypeName(from: argument.expression)
    }
  }
  return (name, formatStyleExpression, formatStyleTypeName)
}

fileprivate func typeInfo(_ type: TypeSyntax) -> (typeName: String, baseTypeName: String, isOptional: Bool) {
  if let optionalType = type.as(OptionalTypeSyntax.self) {
    let base = optionalType.wrappedType.trimmedDescription
    return ("\(base)?", base, true)
  }
  if let identifier = type.as(IdentifierTypeSyntax.self),
    identifier.name.text == "Optional",
    let genericArgs = identifier.genericArgumentClause?.arguments,
    let first = genericArgs.first
  {
    let base = first.argument.trimmedDescription
    return ("\(base)?", base, true)
  }
  let typeName = type.trimmedDescription
  return (typeName, typeName, false)
}

fileprivate struct FormatStyleInfo {
  var expression: String
  var typeName: String?
}

fileprivate func formatStyleExpression(
  typeName: String,
  baseTypeName: String,
  isOptional: Bool,
  override: String?,
  overrideTypeName: String?
) -> FormatStyleInfo {
  if let override {
    let qualifiedTypeName = overrideTypeName.map { qualifyFormatStyleTypeName($0) }
    if isOptional {
      if shouldWrapOptionalFormatStyle(overrideTypeName: qualifiedTypeName, overrideExpression: override) == false {
        return .init(expression: override, typeName: qualifiedTypeName)
      }
      let wrappedTypeName = qualifiedTypeName ?? "D1Lite.D1CodableFormatStyle<\(typeName)>"
      return .init(
        expression: "D1Lite.D1OptionalFormatStyle(\(override))",
        typeName: "D1Lite.D1OptionalFormatStyle<\(wrappedTypeName)>"
      )
    }
    return .init(expression: override, typeName: qualifiedTypeName)
  }
  if isOptional {
    let inner = baseFormatStyleExpression(typeName: baseTypeName, baseTypeName: baseTypeName)
    return .init(
      expression: "D1Lite.D1OptionalFormatStyle(\(inner.expression))",
      typeName: "D1Lite.D1OptionalFormatStyle<\(inner.typeName ?? "D1Lite.D1CodableFormatStyle<\(baseTypeName)>")>"
    )
  }
  return baseFormatStyleExpression(typeName: typeName, baseTypeName: baseTypeName)
}

fileprivate func baseFormatStyleExpression(typeName: String, baseTypeName: String) -> FormatStyleInfo {
  switch baseTypeNameForFormat(baseTypeName) {
  case "UUID":
    return .init(expression: "D1Lite.D1UUIDFormatStyle()", typeName: "D1Lite.D1UUIDFormatStyle")
  case "String":
    return .init(expression: "D1Lite.D1StringFormatStyle()", typeName: "D1Lite.D1StringFormatStyle")
  case "Int":
    return .init(expression: "D1Lite.D1IntFormatStyle()", typeName: "D1Lite.D1IntFormatStyle")
  case "Double":
    return .init(expression: "D1Lite.D1DoubleFormatStyle()", typeName: "D1Lite.D1DoubleFormatStyle")
  case "Bool":
    return .init(expression: "D1Lite.D1BoolFormatStyle()", typeName: "D1Lite.D1BoolFormatStyle")
  case "Date":
    return .init(
      expression: "D1Lite.D1DateFormatStyle(format: D1Lite.D1FormatStyle.DateFormat.iso8601)",
      typeName: "D1Lite.D1DateFormatStyle"
    )
  case "Data":
    return .init(expression: "D1Lite.D1DataFormatStyle()", typeName: "D1Lite.D1DataFormatStyle")
  default:
    return .init(
      expression: "D1Lite.D1CodableFormatStyle<\(typeName)>()",
      typeName: "D1Lite.D1CodableFormatStyle<\(typeName)>"
    )
  }
}

fileprivate func inferFormatStyleTypeName(from expression: ExprSyntax) -> String? {
  guard let call = expression.as(FunctionCallExprSyntax.self) else {
    return nil
  }
  let called = call.calledExpression.trimmedDescription
  if called.hasPrefix(".") {
    return nil
  }
  return called.isEmpty ? nil : called
}

fileprivate func baseTypeNameForFormat(_ baseTypeName: String) -> String {
  if baseTypeName.hasPrefix("Foundation.") {
    return String(baseTypeName.split(separator: ".").last ?? Substring(baseTypeName))
  }
  if baseTypeName.hasPrefix("Swift.") {
    return String(baseTypeName.split(separator: ".").last ?? Substring(baseTypeName))
  }
  return baseTypeName
}

fileprivate func qualifyFormatStyleTypeName(_ typeName: String) -> String {
  guard typeName.contains(".") == false else {
    return typeName
  }
  if typeName.hasPrefix("D1") {
    return "D1Lite.\(typeName)"
  }
  return typeName
}

fileprivate func shouldWrapOptionalFormatStyle(overrideTypeName: String?, overrideExpression: String) -> Bool {
  if let overrideTypeName, overrideTypeName.contains("D1OptionalFormatStyle") {
    return false
  }
  if overrideExpression.contains("D1OptionalFormatStyle") {
    return false
  }
  return true
}

fileprivate func stringLiteralValue(_ expr: ExprSyntax) -> String? {
  guard let stringLiteral = expr.as(StringLiteralExprSyntax.self) else {
    return nil
  }
  return stringLiteral.segments
    .compactMap { segment in
      segment.as(StringSegmentSyntax.self)?.content.text
    }
    .joined()
}

fileprivate func buildInitializer(columns: [ColumnInfo]) -> String {
  let params = columns.map { "\($0.propertyName): \($0.typeName)" }.joined(separator: ", ")
  var lines = ["init(\(params)) {"]
  lines.append(contentsOf: columns.map { "  self.\($0.propertyName) = \($0.propertyName)" })
  lines.append("}")
  return lines.joined(separator: "\n")
}

fileprivate func buildSchema(schema: String) -> String {
  "static let schema = \"\(schema)\""
}

fileprivate func buildColumnsList(columns: [ColumnInfo]) -> String {
  let columnList = columns.map { "\"\($0.columnName)\"" }.joined(separator: ", ")
  return "static let columns = [\(columnList)]"
}

fileprivate func buildColumnDeclaration(column: ColumnInfo) -> String {
  if let formatStyleTypeName = column.formatStyleTypeName {
    return """
      static let \(column.propertyName): D1Lite.D1Column<\(column.typeName), \(formatStyleTypeName)> = D1Lite.D1Column(
        name: \"\(column.columnName)\",
        formatStyle: \(column.formatStyle)
      )
      """
  }
  return
    "static let \(column.propertyName) = D1Lite.D1Column(name: \"\(column.columnName)\", formatStyle: \(column.formatStyle))"
}

fileprivate func buildAllColumnNames(columns: [ColumnInfo]) -> String {
  let columnList = columns.map { "Self.\($0.propertyName).name" }.joined(separator: ", ")
  return "static let allColumnNames: [Swift.String] = [\(columnList)]"
}

fileprivate func buildAllD1Values(columns: [ColumnInfo]) -> String {
  let values = columns.map { "Self.\($0.propertyName).format(value: \($0.propertyName))" }.joined(separator: ", ")
  return """
    var allD1Values: [D1Lite.D1Value] {
      [\(values)]
    }
    """
}

fileprivate func buildD1Format(columns: [ColumnInfo]) -> String {
  let cases =
    columns.map { column -> String in
      "  case \\Self.\(column.propertyName): Self.\(column.propertyName).format(any: value)"
    }
    .joined(separator: "\n")
  return [
    "static func d1Format<Value: Swift.Sendable>(_ keyPath: Swift.KeyPath<Self, Value>, value: Value) -> D1Lite.D1Value {",
    "  switch keyPath {",
    cases,
    "  default: fatalError(\"未対応のキーです。\")",
    "  }",
    "}",
  ]
  .joined(separator: "\n")
}

fileprivate func buildD1ColumnName(columns: [ColumnInfo]) -> String {
  let cases =
    columns.map { column -> String in
      "  case \\Self.\(column.propertyName): Self.\(column.propertyName).name"
    }
    .joined(separator: "\n")
  return [
    "static func d1ColumnName<Value: Swift.Sendable>(_ keyPath: Swift.KeyPath<Self, Value>) -> Swift.String {",
    "  switch keyPath {",
    cases,
    "  default: fatalError(\"未対応のキーです。\")",
    "  }",
    "}",
  ]
  .joined(separator: "\n")
}

fileprivate func buildDecode(columns: [ColumnInfo]) -> String {
  let args =
    columns.map { column -> String in
      "    \(column.propertyName): try Self.\(column.propertyName).parse(d1: \(column.propertyName)Value)"
    }
    .joined(separator: ",\n")
  let guards = columns.map { column -> String in
    """
      guard let \(column.propertyName)Value = record["\(column.columnName)"] else {
        throw D1Lite.D1TableDecodingError.missingValue(property: "\(column.propertyName)", column: "\(column.columnName)")
      }
    """
  }
  let guardLines = guards.joined(separator: "\n")
  let lines = [
    "static func decode(d1 record: [Swift.String: D1Lite.D1Value]) throws -> Self {",
    guardLines,
    "  return self.init(",
    args,
    "  )",
    "}",
  ]
  return lines.joined(separator: "\n")
}

fileprivate func hasD1TableConformance(_ inheritance: InheritanceClauseSyntax?) -> Bool {
  guard let inheritance else {
    return false
  }
  for type in inheritance.inheritedTypes {
    let trimmed = type.type.trimmedDescription
    if trimmed == "D1Table" || trimmed == "D1Lite.D1Table" {
      return true
    }
  }
  return false
}
