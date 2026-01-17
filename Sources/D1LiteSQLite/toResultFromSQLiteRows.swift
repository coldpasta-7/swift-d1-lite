import D1Lite
import SQLiteNIO

/// SQLite のカラム情報を D1 互換のカラム情報とレコードに変換します.
/// - Parameter rows: カラム名と SQLite データの組の配列.
/// - Returns: カラム名配列とレコード配列.
func toResultFromSQLiteDataRows(
  _ rows: [[(name: String, data: SQLiteData)]]
) -> ([String], [[String: D1Value]]) {
  guard let first = rows.first else {
    return ([], [])
  }
  let columns = first.map(\.name)
  let records = rows.map { row in
    var record: [String: D1Value] = [:]
    record.reserveCapacity(row.count)
    for column in row {
      record[column.name] = toSQLiteDataFromD1Value(column.data)
    }
    return record
  }
  return (columns, records)
}
