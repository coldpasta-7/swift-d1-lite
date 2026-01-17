public import Foundation

/// Data を D1 の値へ変換するフォーマットスタイルです.
public struct D1DataFormatStyle: Sendable, ParseableFormatStyle {
  /// フォーマットスタイルを作成.
  public init() {}

  /// Data の解析戦略.
  public var parseStrategy: Strategy { .init() }

  /// Data を D1 の値へ変換します.
  public func format(_ value: Data) -> D1Value {
    .string(value.base64EncodedString())
  }

  /// Data の解析戦略.
  public struct Strategy: ParseStrategy {
    /// D1 の値から Base64 データを取り出します.
    public func parse(_ value: D1Value) throws -> Data {
      guard case .string(let string) = value else {
        throw D1FormatStyle.ParseError.requiredString(value)
      }
      guard let data = Data(base64Encoded: string) else {
        throw D1FormatStyle.ParseError.invalidFormat(value, typename: "Data", message: "Base64 形式である必要があります.")
      }
      return data
    }
  }
}
