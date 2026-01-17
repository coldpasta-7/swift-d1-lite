public import Foundation

/// Unix エポック（秒）形式で日付を D1 の値へ変換するフォーマットスタイルです.
public struct D1DateEpochFormatStyle: Sendable, ParseableFormatStyle {
  /// フォーマットスタイルを作成.
  public init() {}

  /// 日付の解析戦略.
  public var parseStrategy: Strategy { .init() }

  /// 日付を D1 の値へ変換します.
  public func format(_ value: Date) -> D1Value {
    .number(value.timeIntervalSince1970)
  }

  /// 日付の解析戦略.
  public struct Strategy: ParseStrategy {
    /// D1 の値から日付を取り出します.
    public func parse(_ value: D1Value) throws -> Date {
      guard case .number(let number) = value else {
        throw D1FormatStyle.ParseError.requiredNumber(value)
      }
      return Date(timeIntervalSince1970: number)
    }
  }
}
