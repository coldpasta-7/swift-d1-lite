/// D1 の値型を表す列挙です.
///
/// JSON の null は `.null` として扱います.
public enum D1Value: Sendable, Hashable, Codable {
  /// 数値の値です.
  case number(Double)
  /// 文字列の値です.
  case string(String)
  /// null の値です.
  case null

  /// デコーダーから値を復元します.
  public init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    self =
      if container.decodeNil() {
        .null
      } else if let number = try? container.decode(Double.self) {
        .number(number)
      } else {
        .string(try container.decode(String.self))
      }
  }

  /// エンコーダーに値を出力します.
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .null: try container.encodeNil()
    case .number(let number): try container.encode(number)
    case .string(let string): try container.encode(string)
    }
  }
}
