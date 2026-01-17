public import Foundation

/// 整数を D1 の値へ変換するフォーマットスタイルです.
public struct D1IntFormatStyle: Sendable, ParseableFormatStyle {
  /// フォーマットスタイルを作成.
  public init() {}

  /// 整数の解析戦略です.
  public var parseStrategy: Strategy { .init() }

  /// 整数を D1 の値へ変換します.
  public func format(_ value: Int) -> D1Value {
    .number(Double(value))
  }

  /// 整数の解析戦略です.
  public struct Strategy: ParseStrategy {
    /// D1 の値から整数を取り出します.
    public func parse(_ value: D1Value) throws -> Int {
      guard case .number(let number) = value else {
        throw D1FormatStyle.ParseError.requiredNumber(value)
      }
      let int = Int(number)
      guard Double(int) == number else {
        throw D1FormatStyle.ParseError.requiredInteger(value)
      }
      return int
    }
  }
}
