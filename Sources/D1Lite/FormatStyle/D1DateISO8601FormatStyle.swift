public import Foundation

/// ISO 8601 形式で日付を D1 の値へ変換するフォーマットスタイルです.
public struct D1DateISO8601FormatStyle: Sendable, ParseableFormatStyle {
  /// フォーマットスタイルを作成.
  public init() {}

  /// 日付の解析戦略.
  public var parseStrategy: Strategy { .init() }

  /// 日付を D1 の値へ変換します.
  public func format(_ value: Date) -> D1Value {
    .string(Date.ISO8601FormatStyle().format(value))
  }

  /// 日付の解析戦略です.
  public struct Strategy: ParseStrategy {
    /// D1 の値から日付を取り出します.
    public func parse(_ value: D1Value) throws -> Date {
      guard case .string(let string) = value else {
        throw D1FormatStyle.ParseError.requiredString(value)
      }
      return try Date.ISO8601FormatStyle().parse(string)
    }
  }
}
