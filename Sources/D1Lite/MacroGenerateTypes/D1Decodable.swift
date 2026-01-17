/// D1 のレコードから値を復元するためのプロトコル.
public protocol D1Decodable: Sendable {
  /// 単一レコードから値を復元する.
  static func decode(d1 record: [String: D1Value]) throws -> Self
}
