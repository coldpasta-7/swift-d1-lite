import D1Lite
import SQLiteNIO
import Testing

@testable import D1LiteSQLite

@Suite struct ToD1RawDatabaseQueryClientErrorFromErrorTests {
  @Test func passThrough() {
    let expected = D1RawDatabaseQueryClientError(
      errors: [.init(code: 1, message: "oops")],
      messages: []
    )

    let actual = toD1RawDatabaseQueryClientErrorFromError(expected)

    #expect(actual == expected)
  }

  @Test func fallbackError() {
    enum TestError: Error { case sample }

    let actual = toD1RawDatabaseQueryClientErrorFromError(TestError.sample)

    #expect(
      actual
        == .init(
          errors: [
            .init(
              code: 7500,
              message: "sample",
              documentationURL: nil,
              source: nil,
            )
          ],
          messages: [],
        )
    )
  }

  @Test func sqliteError() async throws {
    let connection = try await SQLiteConnection.open(storage: .memory)
    defer { Task { try? await connection.close() } }

    do {
      _ = try await connection.query("INVALID SQL")
      Issue.record("should be throw error SQLiteError but not throwed")
    } catch let error as SQLiteError {
      #expect(
        toD1RawDatabaseQueryClientErrorFromError(error)
          == .init(
            errors: [
              .init(code: 7500, message: #"near "INVALID": syntax error: SQLITE_ERROR"#)
            ],
            messages: []
          )
      )
    } catch {
      Issue.record(error)
    }
  }
}
