extension D1Table {
  /// 1 件分の INSERT クエリを生成します.
  public func create() -> D1Query<D1Void> {
    let d1 = D1SQLDatabase()
    _ = d1.insert(into: Self.schema).columns(Self.allColumnNames).values(allD1Values).run()
    let statement = d1.statement!
    return .init(statement: statement.sql, params: statement.params)
  }
}

extension Sequence where Element: D1Table {
  /// 複数件の INSERT クエリを生成します.
  public func create() -> D1Query<D1Void> {
    var iterator = makeIterator()
    guard let first = iterator.next() else {
      return .init(statement: "SELECT 1", params: [])
    }
    let d1 = D1SQLDatabase()
    var insert = d1.insert(into: Element.schema).columns(Element.allColumnNames).values(first.allD1Values)
    while let next = iterator.next() {
      insert = insert.values(next.allD1Values)
    }
    _ = insert.run()
    let statement = d1.statement!
    return .init(statement: statement.sql, params: statement.params)
  }
}
