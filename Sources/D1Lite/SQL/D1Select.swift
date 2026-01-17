import SQLKit

extension D1Table {
  /// 取得クエリのビルダーを作成します.
  public static func select() -> D1Select<Self> {
    .init(whereClause: .empty)
  }
}

/// D1 の SELECT クエリを組み立てる型です.
public struct D1Select<Table: D1Table>: Sendable, Hashable {
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

  /// 単一行取得のクエリを生成します.
  public func first() -> D1Query<Table?> {
    let db = D1SQLDatabase()
    let select = Table.allColumnNames.reduce(db.select()) { builder, column in
      builder.column(column)
    }
    let selectFrom = select.from(Table.schema)
    func addWhere(builder: SQLSelectBuilder, whereClause: WhereClause<Table>) -> SQLSelectBuilder {
      switch whereClause {
      case .empty: builder
      case .equal(let column, let value): builder.where(column, .equal, value)
      case .and(let lhs, let rhs): addWhere(builder: addWhere(builder: builder, whereClause: lhs), whereClause: rhs)
      }
    }
    let selectFromWhere = addWhere(builder: selectFrom, whereClause: whereClause)
    _ = selectFromWhere.first()
    let statement = db.statement!
    return .init(statement: statement.sql, params: statement.params)
  }

  /// 複数行取得のクエリを生成します.
  public func all() -> D1Query<Set<Table>> {
    let db = D1SQLDatabase()
    let select = Table.allColumnNames.reduce(db.select()) { builder, column in
      builder.column(column)
    }
    let selectFrom = select.from(Table.schema)
    func addWhere(builder: SQLSelectBuilder, whereClause: WhereClause<Table>) -> SQLSelectBuilder {
      switch whereClause {
      case .empty: builder
      case .equal(let column, let value): builder.where(column, .equal, value)
      case .and(let lhs, let rhs): addWhere(builder: addWhere(builder: builder, whereClause: lhs), whereClause: rhs)
      }
    }
    let selectFromWhere = addWhere(builder: selectFrom, whereClause: whereClause)
    _ = selectFromWhere.all()
    let statement = db.statement!
    return .init(statement: statement.sql, params: statement.params)
  }
}
