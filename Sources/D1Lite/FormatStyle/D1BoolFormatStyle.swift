public import Foundation

/// 真偽値を D1 の値へ変換するフォーマットスタイルです.
public struct D1BoolFormatStyle: Sendable, ParseableFormatStyle {
  /// フォーマットスタイルを作成.
  public init() {}

  /// 真偽値の解析戦略.
  public var parseStrategy: Strategy { .init() }

  /// 真偽値を ``D1Value``へ変換する.
  public func format(_ value: Bool) -> D1Value {
    .number(value ? 1 : 0)
  }

  /// 真偽値の解析戦略.
  public struct Strategy: ParseStrategy {
    /// D1 の値から真偽値を取り出します.
    public func parse(_ value: D1Value) throws -> Bool {
      guard case .number(let number) = value else {
        throw D1FormatStyle.ParseError.requiredNumber(value)
      }
      switch number {
      case 0: return false
      case 1: return true
      default:
        throw D1FormatStyle.ParseError.invalidFormat(
          value,
          typename: "Bool",
          message: "0 または 1 である必要があります。"
        )
      }
    }
  }
}
