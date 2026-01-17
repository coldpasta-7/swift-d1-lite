/// カラムの等価条件を組み立てます.
public func == <Table: D1Table, Value: Sendable>(
  lhs: KeyPath<Table, Value>,
  rhs: Value
) -> WhereClause<Table> {
  WhereClause.equal(column: Table.d1ColumnName(lhs), value: Table.d1Format(lhs, value: rhs))
}

/// テーブル検索条件をまとめる型です.
public indirect enum WhereClause<Table: D1Table>: Sendable, Hashable {
  case empty
  case equal(column: String, value: D1Value)
  case and(Self, Self)

  func and(_ clause: Self) -> Self {
    if case .empty = self {
      clause
    } else {
      .and(self, clause)
    }
  }
}
