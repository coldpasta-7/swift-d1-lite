/// D1 テーブル用ヘルパーを生成するマクロです.
@attached(member, names: arbitrary)
@attached(extension, conformances: D1Table)
public macro D1Table(schema: String) =
  #externalMacro(module: "D1LiteMacro", type: "D1TableMacro")

/// 保存プロパティを D1 テーブルのカラムとして指定するマクロです.
@attached(peer)
public macro D1Column(name: String? = nil, formatStyle: Any? = nil) =
  #externalMacro(module: "D1LiteMacro", type: "D1ColumnMacro")
