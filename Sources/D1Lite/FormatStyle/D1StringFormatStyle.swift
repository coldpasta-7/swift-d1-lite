public import Foundation

/// 文字列を D1 の値へ変換するフォーマットスタイルです.
public struct D1StringFormatStyle: Sendable, ParseableFormatStyle {
  /// フォーマットスタイルを作成.
  public init() {}

  /// 文字列の解析戦略.
  public var parseStrategy: Strategy { .init() }

  /// 文字列を D1 の値へ変換します.
  public func format(_ value: String) -> D1Value {
    .string(value)
  }
  /// 文字列の解析戦略.
  public struct Strategy: ParseStrategy {
    /// D1 の値から文字列を取り出します.
    public func parse(_ value: D1Value) throws -> String {
      guard case .string(let string) = value else {
        throw D1FormatStyle.ParseError.requiredString(value)
      }
      return string
    }
  }
}
