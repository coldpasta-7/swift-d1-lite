import D1Lite
import Foundation
import Testing

@Suite struct D1SelectTests {
  @Test func 単一値を取得するQueryを作成できる() async throws {
    // Arrange
    let uuid = try #require(UUID(uuidString: "7B1C1F7C-9C6D-4B48-B6E6-24BCA0B773E1"))

    // Act
    let actual = Sample.select()
      .filter(\.id == uuid)
      .filter(\.count == 2)
      .first()

    // Assert
    #expect(
      actual
        == .init(
          statement: #"SELECT "id", "name", "count" FROM "samples" WHERE "id" = ?1 AND "count" = ?2 LIMIT 1"#,
          params: [.string("7B1C1F7C-9C6D-4B48-B6E6-24BCA0B773E1"), .number(2)]
        )
    )
  }

  @Test func 全件取得() async throws {
    // Act
    let actual = User.select()
      .filter(\.double == 3.14)
      .all()

    // Assert
    #expect(
      actual
        == .init(
          statement:
            #"SELECT "id", "name", "birthday", "counter", "double", "created_at", "updated_at", "context", "isLucky" FROM "users" WHERE "double" = ?1"#,
          params: [.number(3.14)]
        )
    )
  }

  @D1Table(schema: "samples")
  struct Sample: D1Table, Hashable {
    @D1Column
    var id: UUID
    @D1Column
    var name: String
    @D1Column
    var count: Int
  }
}

@D1Table(schema: "users")
struct User: Sendable, Hashable {
  @D1Column
  var id: UUID

  @D1Column
  var name: String

  @D1Column(formatStyle: D1DateFormatStyle(format: .yyyyMMdd))
  var birthday: Date

  @D1Column
  var counter: Int?

  @D1Column
  var double: Double

  @D1Column(name: "created_at", formatStyle: D1DateFormatStyle(format: .epoch))
  var createdAt: Date

  @D1Column(name: "updated_at", formatStyle: D1DateFormatStyle(format: .epoch))
  var updatedAt: Date

  @D1Column
  var context: Context

  @D1Column
  var isLucky: Bool

  struct Context: Sendable, Hashable, Codable {
    var authUserID: UUID
    var now: Date
  }
}
