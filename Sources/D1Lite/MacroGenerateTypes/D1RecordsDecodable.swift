/// D1 の複数レコードから値を復元するためのプロトコルです.
public protocol D1RecordsDecodable: Sendable {
  /// 複数レコードから値を復元します.
  static func decode(d1Records: [[String: D1Value]]) throws -> Self
}

extension Array: D1RecordsDecodable where Element: D1Decodable {
  /// 複数レコードから配列を復元します.
  public static func decode(d1Records: [[String: D1Value]]) throws -> [Element] {
    try d1Records.map(Element.decode(d1:))
  }
}

extension Set: D1RecordsDecodable where Element: D1Decodable, Element: Hashable {
  /// 複数レコードから集合を復元します.
  public static func decode(d1Records: [[String: D1Value]]) throws -> Set<Element> {
    Set(try d1Records.map(Element.decode(d1:)))
  }
}

extension Optional: D1RecordsDecodable where Wrapped: D1Decodable {
  /// 複数レコードから値を復元します.
  public static func decode(d1Records: [[String: D1Value]]) throws -> Wrapped? {
    try d1Records.first.map(Wrapped.decode(d1:))
  }
}
