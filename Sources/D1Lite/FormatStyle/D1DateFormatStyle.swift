public import Foundation

/// 指定した形式で日付を D1 の値へ変換するフォーマットスタイルです.
public struct D1DateFormatStyle: Sendable, ParseableFormatStyle {
  /// 日付の変換形式.
  public var format: D1FormatStyle.DateFormat

  /// 指定形式でフォーマットスタイルを作成.
  public init(format: D1FormatStyle.DateFormat) {
    self.format = format
  }

  /// 日付の解析戦略.
  public var parseStrategy: Strategy { .init(format: format) }

  /// 日付を D1 の値へ変換します.
  public func format(_ value: Date) -> D1Value {
    switch format {
    case .epoch:
      return D1DateEpochFormatStyle().format(value)
    case .yyyyMMdd:
      return D1DateYYYYMMDDFormatStyle().format(value)
    case .iso8601:
      return D1DateISO8601FormatStyle().format(value)
    }
  }

  /// 日付の解析戦略です.
  public struct Strategy: ParseStrategy {
    let format: D1FormatStyle.DateFormat

    /// D1 の値から日付を取り出します.
    public func parse(_ value: D1Value) throws -> Date {
      switch format {
      case .epoch:
        try D1DateEpochFormatStyle().parseStrategy.parse(value)
      case .yyyyMMdd:
        try D1DateYYYYMMDDFormatStyle().parseStrategy.parse(value)
      case .iso8601:
        try D1DateISO8601FormatStyle().parseStrategy.parse(value)
      }
    }
  }
}
