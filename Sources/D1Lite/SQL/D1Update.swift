import SQLKit

extension D1Table {
  /// 更新クエリのビルダーを作成します.
  public static func update() -> D1Update<Self> {
    .init(whereClause: .empty, setClause: [:])
  }
}

/// D1 の UPDATE クエリを組み立てる型です.
public struct D1Update<Table: D1Table>: Sendable, Hashable {
  /// 絞り込み条件です.
  public var whereClause: WhereClause<Table>
  /// 更新するカラムと値の組です.
  public var setClause: [String: D1Value]

  /// 条件と更新内容を指定して作成します.
  public init(whereClause: WhereClause<Table>, setClause: [String: D1Value]) {
    self.whereClause = whereClause
    self.setClause = setClause
  }

  /// 条件を追加した新しいビルダーを返します.
  public func filter(_ clause: WhereClause<Table>) -> Self {
    var next = self
    next.whereClause = whereClause.and(clause)
    return next
  }

  /// 補完を改善するためのオーバーロードです.
  ///
  /// 実行時に失敗します.
  @available(*, deprecated, message: "Use filter(\\.id == value)")
  public func filter<Value: Sendable>(_ keyPath: KeyPath<Table, Value>) -> Self {
    fatalError("This overload exists only to improve code completion.")
  }

  /// 更新対象のカラムと値を追加します.
  public func set<Value: Sendable>(_ keyPath: KeyPath<Table, Value>, _ value: Value) -> Self {
    var next = self
    let column = Table.d1ColumnName(keyPath)
    next.setClause[column] = Table.d1Format(keyPath, value: value)
    return next
  }

  /// クエリを生成します.
  public func build() -> D1Query<D1Void> {
    let db = D1SQLDatabase()
    let update = db.update(Table.schema)
    func addWhere(builder: SQLUpdateBuilder, whereClause: WhereClause<Table>) -> SQLUpdateBuilder {
      switch whereClause {
      case .empty: builder
      case .equal(let column, let value): builder.where(column, .equal, value)
      case .and(let lhs, let rhs): addWhere(builder: addWhere(builder: builder, whereClause: lhs), whereClause: rhs)
      }
    }
    let updateSet = setClause.reduce(update) { (builder, keyValue) in
      let (column, value) = keyValue
      return builder.set(column, to: value)
    }
    let updateSetWhere = addWhere(builder: updateSet, whereClause: whereClause)
    _ = updateSetWhere.run()
    let statement = db.statement!
    return .init(statement: statement.sql, params: statement.params)
  }
}
