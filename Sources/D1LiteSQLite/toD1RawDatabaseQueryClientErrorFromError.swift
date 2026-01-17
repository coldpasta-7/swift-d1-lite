import D1Lite
import SQLiteNIO

/// 任意のエラーを `D1RawDatabaseQueryClientError` に変換します.
/// - Parameter error: 変換対象のエラー.
/// - Returns: D1 のエラー表現.
///
/// `D1RawDatabaseQueryClientError` はそのまま返し、`SQLiteError` は SQLite 由来のメッセージに変換します.
/// それ以外のエラーは `String(describing:)` による説明を返します.
func toD1RawDatabaseQueryClientErrorFromError(_ error: any Error) -> D1RawDatabaseQueryClientError {
  if let d1Error = error as? D1RawDatabaseQueryClientError {
    return d1Error
  }
  if let sqliteError = error as? SQLiteNIO.SQLiteError {
    return toD1RawDatabaseQueryClientError(reason: sqliteError.reason, message: sqliteError.message)
  }
  return D1RawDatabaseQueryClientError(
    errors: [
      D1ResponseInfo(code: 7500, message: String(describing: error))
    ],
    messages: []
  )
}
