import AsyncHTTPClient
import Configuration
import D1Lite
import D1LiteAsyncHTTPClient
import Foundation
import Testing

@Suite struct AsyncHTTPD1RawDatabaseQueryClientTests {
  @Test func test() async throws {
    let config = ConfigReader(providers: [
      EnvironmentVariablesProvider(),
      try await EnvironmentVariablesProvider(environmentFilePath: ".env.testing", allowMissing: true),
    ])
    try await withAsyncHTTPClient { httpClient in
      let client = try AsyncHTTPD1RawDatabaseQueryClient(httpClient: httpClient, configReader: config)
      let d1 = D1SQLClient(client: client)

      // All Delete
      _ = try await d1.batch(
        TestModel.delete().build(),
        Lock.delete().build(),
      )

      // Create Initial Value
      let uuid = UUID()
      let fixedEpoch = Date(timeIntervalSince1970: 1_725_000_000)
      let initial = TestModel(
        id: uuid,
        name: "Bob",
        dateYMD: try Date.ISO8601FormatStyle().parse("2025-07-14T00:00:00Z"),
        dateISO: try Date.ISO8601FormatStyle().parse("2026-12-31T12:34:56Z"),
        dateEpoch: fixedEpoch,
        count: 3,
        ratio: 3.14,
        blob: Data([1, 2, 3, 4]),
        payload: .init(auth: "user", role: "admin"),
      )
      let initialLock = Lock(tableName: TestModel.schema, seqNr: 1, createdAt: fixedEpoch)

      let (firstTestModels, firstLocks, _, _, secondTestModel, secondLock) = try await d1.batch(
        TestModel.select().all(),
        Lock.select().all(),
        initial.create(),
        initialLock.create(),
        TestModel.select().filter(\.id == uuid).first(),
        Lock.select().first(),
      )
      #expect(firstTestModels.value == [])
      #expect(firstLocks.value == [])
      #expect(secondTestModel.value == initial)
      #expect(secondLock.value == initialLock)

      // Update Value
      var update = try #require(secondTestModel.value)
      update.name = "Candy"
      update.dateYMD = try Date.ISO8601FormatStyle().parse("2025-01-01T00:00:00Z")
      update.count = 4
      update.payload = .init(auth: "user", role: "normal")
      let (_, _, thirdTestModel) = try await d1.batch(
        TestModel.update()
          .set(\.name, "Candy")
          .set(\.dateYMD, try Date.ISO8601FormatStyle().parse("2025-01-01T00:00:00Z"))
          .set(\.count, 4)
          .set(\.payload, .init(auth: "user", role: "normal"))
          .filter(\.id == uuid)
          .build(),
        Lock(tableName: TestModel.schema, seqNr: 2, createdAt: Date()).create(),
        TestModel.select()
          .filter(\.id == uuid)
          .first(),
      )
      #expect(thirdTestModel.value == update)

      // 楽観的ロックによる更新失敗
      await #expect(
        throws: D1RawDatabaseQueryClientError(
          errors: [
            .init(code: 7500, message: "UNIQUE constraint failed: locks.table_name, locks.seq_nr: SQLITE_CONSTRAINT")
          ],
          messages: []
        )
      ) {
        try await d1.batch(
          TestModel.update()
            .set(\.name, "Alice")
            .set(\.count, 5)
            .filter(\.id == uuid)
            .build(),
          Lock(tableName: TestModel.schema, seqNr: 2, createdAt: Date()).create(),
        )
      }
    }
  }

  func withAsyncHTTPClient(action: @Sendable (HTTPClient) async throws -> Void) async throws {
    let client = HTTPClient()
    do {
      try await action(client)
    } catch {
      try await client.shutdown()
      throw error
    }
    try await client.shutdown()
  }
}

@D1Table(schema: "test_models")
struct TestModel: Sendable, Hashable {
  @D1Column
  var id: UUID

  @D1Column
  var name: String

  @D1Column(name: "date_ymd", formatStyle: D1DateFormatStyle(format: .yyyyMMdd))
  var dateYMD: Date

  @D1Column(name: "date_iso", formatStyle: D1DateFormatStyle(format: .iso8601))
  var dateISO: Date

  @D1Column(name: "date_epoch", formatStyle: D1DateFormatStyle(format: .epoch))
  var dateEpoch: Date

  @D1Column
  var count: Int

  @D1Column
  var ratio: Double

  @D1Column
  var blob: Data

  @D1Column
  var payload: Payload

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
