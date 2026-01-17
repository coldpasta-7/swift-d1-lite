import D1Lite
import SQLiteNIO

/// SQLite の `reason` と `message` から D1 エラーを組み立てます.
/// - Parameters:
///   - reason: SQLite のエラー理由.
///   - message: SQLite のエラーメッセージ.
/// - Returns: D1 のエラー表現.
///
/// 制約違反は `SQLITE_CONSTRAINT`、それ以外は `SQLITE_ERROR` として扱います.
func toD1RawDatabaseQueryClientError(
  reason: SQLiteError.Reason,
  message: String
) -> D1RawDatabaseQueryClientError {
  let code = sqliteErrorCodeString(for: reason)
  let message = message.isEmpty ? code : "\(message): \(code)"
  return D1RawDatabaseQueryClientError(
    errors: [
      D1ResponseInfo(code: 7500, message: message)
    ],
    messages: []
  )
}

fileprivate func sqliteErrorCodeString(for reason: SQLiteNIO.SQLiteError.Reason) -> String {
  switch reason {
  case .constraint,
    .constraintCheckFailed,
    .constraintCommitHookFailed,
    .constraintForeignKeyFailed,
    .constraintUserFunctionFailed,
    .constraintNotNullFailed,
    .constraintPrimaryKeyFailed,
    .constraintTriggerFailed,
    .constraintUniqueFailed,
    .constraintVirtualTableFailed,
    .constraintUniqueRowIDFailed,
    .constraintUpdateTriggerDeletedRow,
    .constraintStrictDataTypeFailed:
    return "SQLITE_CONSTRAINT"
  default:
    return "SQLITE_ERROR"
  }
}
