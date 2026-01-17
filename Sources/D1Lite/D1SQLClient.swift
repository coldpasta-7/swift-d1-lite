/// クエリ実行時のエラーです.
public enum D1SQLClientError: Error, Sendable, Hashable {
  /// 結果数が期待と一致しない場合のエラーです.
  case unexpectedResultCount(expected: Int, actual: Int)
}

/// D1 の生クエリをバッチ実行するクライアントです.
public actor D1SQLClient {
  nonisolated let client: any D1RawDatabaseQueryClient

  /// クライアントを指定して作成します.
  public init(client: any D1RawDatabaseQueryClient) {
    self.client = client
  }

  /// バッチでクエリを実行します.
  @discardableResult
  public nonisolated func batch<each Return>(
    _ query: repeat D1Query<each Return>
  ) async throws -> (repeat D1Result<each Return>) where repeat each Return: D1RecordsDecodable {
    var statements: [D1Statement] = []

    for query in repeat each query {
      statements.append(D1Statement(sql: query.statement, params: query.params))
    }

    let results: [D1QueryResult] =
      if statements.isEmpty {
        []
      } else {
        try await client.batch(statements: statements)
      }

    guard results.count == statements.count else {
      throw D1SQLClientError.unexpectedResultCount(expected: statements.count, actual: results.count)
    }

    var iterator = results.makeIterator()
    return
      (repeat try Self.consumeResult(
        for: (each query),
        from: &iterator,
        statementsCount: statements.count,
        resultsCount: results.count
      ))
  }

  private static func consumeResult<Return>(
    for _: D1Query<Return>,
    from iterator: inout IndexingIterator<[D1QueryResult]>,
    statementsCount: Int,
    resultsCount: Int
  ) throws -> D1Result<Return> where Return: D1RecordsDecodable {
    guard let raw = iterator.next() else {
      throw D1SQLClientError.unexpectedResultCount(expected: statementsCount, actual: resultsCount)
    }
    return D1Result(value: try Return.decode(d1Records: raw.records), meta: raw.meta)
  }
}
