import D1Lite
import Testing

@testable import D1LiteSQLite

@Suite struct ToD1RawDatabaseQueryClientErrorTests {
  @Test func syntaxError() {
    let actual = toD1RawDatabaseQueryClientError(reason: .error, message: "near \"SELEC\": syntax error")

    #expect(
      actual
        == .init(
          errors: [
            .init(
              code: 7500,
              message: "near \"SELEC\": syntax error: SQLITE_ERROR",
              documentationURL: nil,
              source: nil,
            )
          ],
          messages: [],
        )
    )
  }

  @Test func constraintError() {
    let actual = toD1RawDatabaseQueryClientError(
      reason: .constraintUniqueFailed,
      message: "UNIQUE constraint failed: locks.table_name, locks.seq_nr",
    )

    #expect(
      actual
        == .init(
          errors: [
            .init(
              code: 7500,
              message: "UNIQUE constraint failed: locks.table_name, locks.seq_nr: SQLITE_CONSTRAINT",
              documentationURL: nil,
              source: nil,
            )
          ],
          messages: [],
        )
    )
  }
}
