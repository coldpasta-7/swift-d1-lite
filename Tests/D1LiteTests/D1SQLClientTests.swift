import Foundation
import Testing

@testable import D1Lite

@Suite struct D1SQLClientTests {
  @Test func batchで可変長引数のQueryを順序通りにデコードできる() async throws {
    // Arrange
    let sut = D1SQLClient(
      client: StubD1RawDatabaseQueryClient(results: [
        D1QueryResult(
          meta: .init(changedDB: false, changes: 1),
          columns: ["id", "name", "age"],
          records: [
            [
              "id": .string("00000000-0000-0000-0000-000000000001"),
              "name": .string("Alice"),
              "age": .number(30),
            ]
          ],
        ),
        D1QueryResult(
          meta: .init(changedDB: true, changes: 2),
          columns: ["user_id", "height", "body_weight", "date"],
          records: [
            [
              "user_id": .string("00000000-0000-0000-0000-000000000001"),
              "height": .number(170.5),
              "body_weight": .number(60.2),
              "date": .string("2024-01-01"),
            ]
          ],
        ),
        D1QueryResult(
          meta: .init(changedDB: false, changes: 0),
          columns: ["id", "name", "age"],
          records: [
            [
              "id": .string("00000000-0000-0000-0000-000000000002"),
              "name": .string("Bob"),
              "age": .number(25),
            ],
            [
              "id": .string("00000000-0000-0000-0000-000000000003"),
              "name": .string("Carol"),
              "age": .number(28),
            ],
          ],
        ),
        D1QueryResult(
          meta: .init(changedDB: false, changes: 0),
          columns: ["user_id", "height", "body_weight", "date"],
          records: [
            [
              "user_id": .string("00000000-0000-0000-0000-000000000002"),
              "height": .number(180.0),
              "body_weight": .number(70.0),
              "date": .string("2024-02-02"),
            ],
            [
              "user_id": .string("00000000-0000-0000-0000-000000000003"),
              "height": .number(165.2),
              "body_weight": .number(55.3),
              "date": .string("2024-03-03"),
            ],
          ],
        ),
        D1QueryResult(
          meta: .init(changedDB: true, changes: 1),
          columns: [],
          records: [],
        ),
        D1QueryResult(
          meta: .init(changedDB: true, changes: 1),
          columns: [],
          records: [],
        ),
        D1QueryResult(
          meta: .init(changedDB: true, changes: 1),
          columns: [],
          records: [],
        ),
      ])
    )

    // Act
    let (user, measurement, users, measurements, insertResult, updateResult, deleteResult) = try await sut.batch(
      UserTable.select().filter(\.id == UUID()).first(),
      BodyMeasurement.select().filter(\.userID == UUID()).first(),
      UserTable.select().all(),
      BodyMeasurement.select().all(),
      UserTable(
        id: try #require(UUID(uuidString: "00000000-0000-0000-0000-000000000003")),
        name: "Carol",
        age: 42,
      )
      .create(),
      UserTable.update()
        .filter(\.id == UUID())
        .set(\.name, "Dave")
        .set(\.age, 33)
        .build(),
      UserTable.delete().filter(\.id == UUID()).build(),
    )

    // Assert
    #expect(
      user.value
        == UserTable(
          id: try #require(UUID(uuidString: "00000000-0000-0000-0000-000000000001")),
          name: "Alice",
          age: 30,
        )
    )
    #expect(
      measurement.value
        == BodyMeasurement(
          userID: try #require(UUID(uuidString: "00000000-0000-0000-0000-000000000001")),
          身長: 170.5,
          体重: 60.2,
          測定日: try D1DateYYYYMMDDFormatStyle().parseStrategy.parse(.string("2024-01-01")),
        )
    )
    #expect(
      users.value
        == [
          UserTable(
            id: try #require(UUID(uuidString: "00000000-0000-0000-0000-000000000002")),
            name: "Bob",
            age: 25,
          ),
          UserTable(
            id: try #require(UUID(uuidString: "00000000-0000-0000-0000-000000000003")),
            name: "Carol",
            age: 28,
          ),
        ]
    )
    #expect(
      measurements.value
        == [
          BodyMeasurement(
            userID: try #require(UUID(uuidString: "00000000-0000-0000-0000-000000000002")),
            身長: 180.0,
            体重: 70.0,
            測定日: try D1DateYYYYMMDDFormatStyle().parseStrategy.parse(.string("2024-02-02")),
          ),
          BodyMeasurement(
            userID: try #require(UUID(uuidString: "00000000-0000-0000-0000-000000000003")),
            身長: 165.2,
            体重: 55.3,
            測定日: try D1DateYYYYMMDDFormatStyle().parseStrategy.parse(.string("2024-03-03")),
          ),
        ]
    )
    #expect(insertResult.value == .shared)
    #expect(updateResult.value == .shared)
    #expect(deleteResult.value == .shared)
  }

  struct StubD1RawDatabaseQueryClient: D1RawDatabaseQueryClient {
    var results: [D1QueryResult]

    func batch(statements: [D1Statement]) async throws -> [D1QueryResult] {
      results
    }
  }
}

@D1Table(schema: "users")
struct UserTable {
  @D1Column
  var id: UUID

  @D1Column
  var name: String

  @D1Column
  var age: Int
}

@D1Table(schema: "body_measurement")
struct BodyMeasurement {
  @D1Column(name: "user_id")
  var userID: UUID

  @D1Column(name: "height")
  var 身長: Double

  @D1Column(name: "body_weight")
  var 体重: Double

  @D1Column(name: "date", formatStyle: D1DateFormatStyle(format: .yyyyMMdd))
  var 測定日: Date
}
