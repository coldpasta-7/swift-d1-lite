public import Foundation

/// yyyy-MM-dd 形式で日付を D1 の値へ変換するフォーマットスタイルです.
public struct D1DateYYYYMMDDFormatStyle: Sendable, ParseableFormatStyle {
  /// フォーマットスタイルを作成.
  public init() {}

  /// 日付の解析戦略.
  public var parseStrategy: Strategy { .init() }

  /// 日付を D1 の値へ変換します.
  public func format(_ value: Date) -> D1Value {
    .string(Self.formatStyle.format(value))
  }

  private static let formatStyle: Date.ISO8601FormatStyle = .iso8601
    .year()
    .month()
    .day()

  /// 日付の解析戦略.
  public struct Strategy: ParseStrategy {
    /// D1 の値から日付を取り出します.
    public func parse(_ value: D1Value) throws -> Date {
      guard case .string(let string) = value else {
        throw D1FormatStyle.ParseError.requiredString(value)
      }
      return try D1DateYYYYMMDDFormatStyle.formatStyle.parse(string)
    }
  }
}
