public import Foundation

/// D1 のカラム情報を表す構造体.
public struct D1Column<Value: Sendable, Style: ParseableFormatStyle & Sendable>: Sendable
where Style.FormatInput == Value, Style.FormatOutput == D1Value {
  /// カラム名.
  public var name: String
  /// D1 値との変換に使うフォーマットスタイル.
  public var formatStyle: Style

  /// カラム名とフォーマットスタイルを指定して作成.
  public init(name: String, formatStyle: Style) {
    self.name = name
    self.formatStyle = formatStyle
  }

  /// D1 の値を型へ復元する.
  public func parse(d1 value: D1Value) throws -> Value {
    try formatStyle.parseStrategy.parse(value)
  }

  /// 型の値を D1 の値へ変換する.
  public func format(value: Value) -> D1Value {
    formatStyle.format(value)
  }

  /// 任意の値を D1 の値へ変換する.
  public func format<T: Sendable>(any: T) -> D1Value {
    guard let value = any as? Value else { fatalError("any should be \(Value.self) but go \(T.self)") }
    return format(value: value)
  }
}
