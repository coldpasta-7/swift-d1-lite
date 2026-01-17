import SQLKit

extension D1Table {
  /// 削除クエリのビルダーを作成します.
  public static func delete() -> D1Delete<Self> {
    .init(whereClause: .empty)
  }
}

/// D1 の DELETE クエリを組み立てる型です.
public struct D1Delete<Table: D1Table>: Sendable, Hashable {
  /// 絞り込み条件です.
  public var whereClause: WhereClause<Table>

  /// 条件を指定して作成します.
  public init(whereClause: WhereClause<Table>) {
    self.whereClause = whereClause
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

  /// クエリを生成します.
  public func build() -> D1Query<D1Void> {
    let db = D1SQLDatabase()
    let delete = db.delete(from: Table.schema)
    func addWhere(builder: SQLDeleteBuilder, whereClause: WhereClause<Table>) -> SQLDeleteBuilder {
      switch whereClause {
      case .empty: builder
      case .equal(let column, let value): builder.where(column, .equal, value)
      case .and(let lhs, let rhs): addWhere(builder: addWhere(builder: builder, whereClause: lhs), whereClause: rhs)
      }
    }
    let deleteWhere = addWhere(builder: delete, whereClause: whereClause)
    _ = deleteWhere.run()
    let statement = db.statement!
    return .init(statement: statement.sql, params: statement.params)
  }
}
