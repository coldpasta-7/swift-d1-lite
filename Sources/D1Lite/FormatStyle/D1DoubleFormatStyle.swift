public import Foundation

/// 浮動小数を D1 の値へ変換するフォーマットスタイルです.
public struct D1DoubleFormatStyle: Sendable, ParseableFormatStyle {
  /// フォーマットスタイルを作成.
  public init() {}

  /// 浮動小数の解析戦略.
  public var parseStrategy: Strategy { .init() }

  /// 浮動小数を D1 の値へ変換します.
  public func format(_ value: Double) -> D1Value {
    .number(value)
  }

  /// 浮動小数の解析戦略.
  public struct Strategy: ParseStrategy {
    /// D1 の値から浮動小数を取り出します.
    public func parse(_ value: D1Value) throws -> Double {
      guard case .number(let number) = value else {
        throw D1FormatStyle.ParseError.requiredNumber(value)
      }
      return number
    }
  }
}
