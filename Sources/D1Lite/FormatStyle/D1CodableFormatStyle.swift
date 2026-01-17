public import Foundation

/// Codable を D1 の値へ変換するフォーマットスタイルです.
public struct D1CodableFormatStyle<Value: Codable>: Sendable, ParseableFormatStyle {
  /// フォーマットスタイルを作成.
  public init() {}

  /// Codable の解析戦略.
  public var parseStrategy: Strategy { .init() }

  /// Codable を D1 の値へ変換します.
  public func format(_ value: Value) -> D1Value {
    do {
      let encoder = JSONEncoder()
      encoder.outputFormatting = [.sortedKeys]
      let data = try encoder.encode(value)
      guard let string = String(data: data, encoding: .utf8) else {
        fatalError("UTF-8 への変換に失敗しました。\(value)")
      }
      return .string(string)
    } catch {
      fatalError("Codable のエンコードに失敗しました: value: \(value), error: \(error)")
    }
  }
  /// Codable の解析戦略.
  public struct Strategy: ParseStrategy {
    /// D1 の値から Codable をデコードします.
    public func parse(_ value: D1Value) throws -> Value {
      guard case .string(let string) = value else {
        throw D1FormatStyle.ParseError.requiredString(value)
      }
      guard let data = string.data(using: .utf8) else {
        throw D1FormatStyle.ParseError.invalidFormat(
          value,
          typename: "Codable",
          message: "UTF-8 形式である必要があります。"
        )
      }
      return try JSONDecoder().decode(Value.self, from: data)
    }
  }
}
