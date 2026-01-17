/// D1 のクエリ定義を表す型です.
public struct D1Query<Return: D1RecordsDecodable>: Sendable, Hashable, Codable {
  /// 実行する SQL 文です.
  public var statement: String
  /// SQL のバインドパラメータです.
  public var params: [D1Value]

  /// クエリを作成します.
  public init(statement: String, params: [D1Value]) {
    self.statement = statement
    self.params = params
  }
}
