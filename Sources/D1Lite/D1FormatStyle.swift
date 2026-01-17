/// D1 の値と相互変換できるフォーマットスタイルの名前空間です.
public enum D1FormatStyle: Sendable {
  /// 日付の表現形式です.
  public enum DateFormat: String, Sendable, Hashable, Codable {
    /// yyyy-MM-dd 形式です.
    case yyyyMMdd
    /// Unix エポック（秒）形式です.
    case epoch
    /// ISO 8601 形式です.
    case iso8601
  }

  /// 値変換時のエラーです.
  public enum ParseError: Error, Sendable, Hashable {
    /// 文字列型が必要な場合のエラーです.
    case requiredString(D1Value)
    /// 数値型が必要な場合のエラーです.
    case requiredNumber(D1Value)
    /// 整数型が必要な場合のエラーです.
    case requiredInteger(D1Value)
    /// 形式が不正な場合のエラーです.
    case invalidFormat(D1Value, typename: String, message: String)
  }
}
