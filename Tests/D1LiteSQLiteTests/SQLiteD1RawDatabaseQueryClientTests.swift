import D1Lite
import D1LiteSQLite
import Foundation
import Testing

@Suite struct SQLiteD1RawDatabaseQueryClientTests {
  @Test(arguments: [true, false])
  func crudOperations(inMemory: Bool) async throws {
    try await withClient(inMemory: inMemory) { client in
      let d1 = D1SQLClient(client: client)

      _ = try await d1.batch(
        D1Query<D1Void>(
          statement: """
            CREATE TABLE users(
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              age INTEGER NOT NULL,
              score REAL NOT NULL,
              active INTEGER NOT NULL,
              blob TEXT NOT NULL,
              payload TEXT NOT NULL,
              date_epoch INTEGER NOT NULL,
              date_iso TEXT NOT NULL,
              date_ymd TEXT NOT NULL,
              note TEXT,
              opt_int INTEGER,
              count INTEGER NOT NULL
            )
            """,
          params: []
        )
      )

      let userID1 = try #require(UUID(uuidString: "00000000-0000-0000-0000-000000000001"))
      let (initialAll, initialFirst) = try await d1.batch(
        User.select().all(),
        User.select().filter(\.id == userID1).first(),
      )
      #expect(initialAll.value == [])
      #expect(initialFirst.value == nil)

      let user1 = User(
        id: userID1,
        name: "Alice",
        age: 20,
        score: 12.5,
        isActive: true,
        blob: Data([1, 2, 3]),
        payload: .init(auth: "user", role: "admin"),
        dateEpoch: Date(timeIntervalSince1970: 1_725_000_000),
        dateISO: try Date.ISO8601FormatStyle().parse("2026-12-31T12:34:56Z"),
        dateYMD: try Date.ISO8601FormatStyle().parse("2025-01-02T00:00:00Z"),
        note: "hello",
        optionalCount: 7,
        count: 3
      )
      _ = try await d1.batch(user1.create())

      let (afterInsertFirst) = try await d1.batch(
        User.select().filter(\.id == user1.id).first()
      )
      #expect(afterInsertFirst.value == user1)

      let userID2 = try #require(UUID(uuidString: "00000000-0000-0000-0000-000000000002"))
      let user2 = User(
        id: userID2,
        name: "Bob",
        age: 30,
        score: 0.5,
        isActive: false,
        blob: Data([4, 5, 6]),
        payload: .init(auth: "user", role: "viewer"),
        dateEpoch: Date(timeIntervalSince1970: 1_725_100_000),
        dateISO: try Date.ISO8601FormatStyle().parse("2027-01-01T00:00:00Z"),
        dateYMD: try Date.ISO8601FormatStyle().parse("2025-02-01T00:00:00Z"),
        note: nil,
        optionalCount: nil,
        count: 5
      )
      let userID3 = try #require(UUID(uuidString: "00000000-0000-0000-0000-000000000003"))
      let user3 = User(
        id: userID3,
        name: "Cara",
        age: 40,
        score: 99.9,
        isActive: true,
        blob: Data([7, 8, 9]),
        payload: .init(auth: "admin", role: "owner"),
        dateEpoch: Date(timeIntervalSince1970: 1_725_200_000),
        dateISO: try Date.ISO8601FormatStyle().parse("2028-05-20T10:20:30Z"),
        dateYMD: try Date.ISO8601FormatStyle().parse("2025-03-10T00:00:00Z"),
        note: "memo",
        optionalCount: 0,
        count: 8
      )
      _ = try await d1.batch([user2, user3].create())

      let (afterBulkAll) = try await d1.batch(User.select().all())
      #expect(afterBulkAll.value == [user1, user2, user3])

      _ = try await d1.batch(
        User.update()
          .set(\.name, "Bobby")
          .set(\.age, 31)
          .set(\.score, 1.25)
          .set(\.isActive, true)
          .set(\.note, "updated")
          .set(\.optionalCount, 42)
          .filter(\.id == user2.id)
          .build()
      )
      var updatedUser2 = user2
      updatedUser2.name = "Bobby"
      updatedUser2.age = 31
      updatedUser2.score = 1.25
      updatedUser2.isActive = true
      updatedUser2.note = "updated"
      updatedUser2.optionalCount = 42
      let (updatedFirst) = try await d1.batch(
        User.select().filter(\.id == user2.id).first()
      )
      #expect(updatedFirst.value == updatedUser2)

      _ = try await d1.batch(
        User.delete()
          .filter(\.id == user1.id)
          .build()
      )
      let (finalAll) = try await d1.batch(User.select().all())
      #expect(finalAll.value == Set([updatedUser2, user3]))
    }
  }

  @Test(arguments: [true, false])
  func uniqueConstraintError(inMemory: Bool) async throws {
    try await withClient(inMemory: inMemory) { client in
      let d1 = D1SQLClient(client: client)

      _ = try await d1.batch(
        D1Query<D1Void>(
          statement: """
            CREATE TABLE locks(
              table_name TEXT NOT NULL,
              seq_nr INTEGER NOT NULL,
              created_at INTEGER NOT NULL,
              UNIQUE(table_name, seq_nr)
            )
            """,
          params: []
        )
      )

      let lock = Lock(tableName: "users", seqNr: 1, createdAt: Date(timeIntervalSince1970: 1))
      let duplicate = Lock(tableName: "users", seqNr: 1, createdAt: Date(timeIntervalSince1970: 2))

      await #expect(
        throws: D1RawDatabaseQueryClientError(
          errors: [
            .init(code: 7500, message: "UNIQUE constraint failed: locks.table_name, locks.seq_nr: SQLITE_CONSTRAINT")
          ],
          messages: []
        )
      ) {
        try await d1.batch(lock.create(), duplicate.create())
      }
    }
  }

  private func withClient(
    inMemory: Bool,
    action: @Sendable (SQLiteD1RawDatabaseQueryClient) async throws -> Void
  ) async throws {
    let uuid = UUID()
    let filePathURL = FileManager.default.temporaryDirectory.appending(path: "\(uuid)-test.db")

    let config: SQLiteD1RawDatabaseQueryClient.Configuration =
      if inMemory {
        .inMemory
      } else {
        .file(.init(filePathURL.path(percentEncoded: false)))
      }

    let client = SQLiteD1RawDatabaseQueryClient(config: config)

    do {
      try await action(client)
      try? await client.shutdown()
      try? FileManager.default.removeItem(atPath: filePathURL.path(percentEncoded: false))
    } catch {
      try? await client.shutdown()
      try? FileManager.default.removeItem(atPath: filePathURL.path(percentEncoded: false))
      throw error
    }
  }
}

@D1Table(schema: "users")
struct User: Sendable, Hashable {
  @D1Column
  var id: UUID

  @D1Column
  var name: String

  @D1Column
  var age: Int

  @D1Column
  var score: Double

  @D1Column(name: "active")
  var isActive: Bool

  @D1Column
  var blob: Data

  @D1Column
  var payload: Payload

  @D1Column(name: "date_epoch", formatStyle: D1DateFormatStyle(format: .epoch))
  var dateEpoch: Date

  @D1Column(name: "date_iso", formatStyle: D1DateFormatStyle(format: .iso8601))
  var dateISO: Date

  @D1Column(name: "date_ymd", formatStyle: D1DateFormatStyle(format: .yyyyMMdd))
  var dateYMD: Date

  @D1Column(name: "note")
  var note: String?

  @D1Column(name: "opt_int")
  var optionalCount: Int?

  @D1Column(name: "count")
  var count: Int

  struct Payload: Sendable, Hashable, Codable {
    var auth: String
    var role: String
  }
}

@D1Table(schema: "locks")
struct Lock: Sendable, Hashable {
  @D1Column(name: "table_name")
  var tableName: String

  @D1Column(name: "seq_nr")
  var seqNr: Int

  @D1Column(name: "created_at", formatStyle: D1DateFormatStyle(format: .epoch))
  var createdAt: Date
}
