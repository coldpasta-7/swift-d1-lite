public import Foundation

/// Optional を D1 の値へ変換するフォーマットスタイルです.
public struct D1OptionalFormatStyle<WrappedStyle: ParseableFormatStyle & Sendable>: Sendable, ParseableFormatStyle
where WrappedStyle.FormatOutput == D1Value {
  /// 内部で利用するフォーマットスタイルです.
  public var wrapped: WrappedStyle

  /// フォーマットスタイルを作成.
  public init(_ wrapped: WrappedStyle) {
    self.wrapped = wrapped
  }

  /// Optional を D1 の値へ変換します.
  public func format(_ value: WrappedStyle.FormatInput?) -> D1Value {
    guard let value else {
      return .null
    }
    return wrapped.format(value)
  }

  /// フォーマット入力型.
  public typealias FormatInput = WrappedStyle.FormatInput?
  /// フォーマット出力型.
  public typealias FormatOutput = D1Value

  /// Optional の解析戦略.
  public var parseStrategy: Strategy { .init(wrapped: wrapped) }

  /// Optional の解析戦略.
  public struct Strategy: ParseStrategy {
    let wrapped: WrappedStyle

    /// D1 の値から Optional を取り出します.
    public func parse(_ value: D1Value) throws -> WrappedStyle.FormatInput? {
      switch value {
      case .null: nil
      case .string(_), .number(_): try wrapped.parseStrategy.parse(value)
      }
    }
  }
}
