import D1Lite
import Testing

@Suite struct D1CreateTests {
  @Test func 複数件を一括作成するQueryを作成できる() async throws {
    // Act
    let actual = [
      Sample(id: "1", name: "Alice", count: 1),
      Sample(id: "2", name: "Bob", count: 2),
    ]
    .create()

    // Assert
    #expect(
      actual
        == .init(
          statement:
            #"INSERT INTO "samples" ("id", "name", "count") VALUES (?1, ?2, ?3), (?4, ?5, ?6)"#,
          params: [
            .string("1"),
            .string("Alice"),
            .number(1),
            .string("2"),
            .string("Bob"),
            .number(2),
          ]
        )
    )
  }

  @D1Table(schema: "samples")
  struct Sample: D1Table, Hashable {
    @D1Column
    var id: String
    @D1Column
    var name: String
    @D1Column
    var count: Int
  }
}
