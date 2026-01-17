/// クエリ結果を表す型です.
public struct D1Result<Value: D1RecordsDecodable>: Sendable {
  /// デコード済みの値です.
  public var value: Value
  /// メタ情報です.
  public var meta: D1QueryResult.Meta

  /// 値とメタ情報を指定して作成します.
  public init(value: Value, meta: D1QueryResult.Meta) {
    self.value = value
    self.meta = meta
  }
}

extension D1Result: Equatable where Value: Equatable {}
extension D1Result: Hashable where Value: Hashable {}
