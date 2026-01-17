import D1Lite
import Foundation
import SQLiteNIO

/// SQLite のデータを D1 の値へ変換します.
/// - Parameter data: SQLite のデータ.
/// - Returns: D1 の値.
///
/// BLOB は Base64 文字列に変換して返します.
func toSQLiteDataFromD1Value(_ data: SQLiteData) -> D1Value {
  switch data {
  case .integer(let value): .number(Double(value))
  case .float(let value): .number(value)
  case .text(let value): .string(value)
  case .blob(let buffer): .string(Data(buffer.readableBytesView).base64EncodedString())
  case .null: .null
  }
}
