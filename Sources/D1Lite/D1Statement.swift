/// SQL とパラメータの組を表す型です.
public struct D1Statement: Sendable, Hashable, Codable {
  /// SQL 文です.
  public var sql: String
  /// バインドパラメータです.
  public var params: [D1Value]

  /// SQL とパラメータを指定して作成します.
  public init(sql: String, params: [D1Value]) {
    self.sql = sql
    self.params = params
  }
}
