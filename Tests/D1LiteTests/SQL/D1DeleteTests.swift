import D1Lite
import Foundation
import Testing

@Suite struct D1DeleteTests {
  @Test func 削除Queryを作成できる() async throws {
    // Arrange
    let uuid = try #require(UUID(uuidString: "7B1C1F7C-9C6D-4B48-B6E6-24BCA0B773E1"))

    // Act
    let actual = User.delete()
      .filter(\.id == uuid)
      .build()

    // Assert
    #expect(
      actual
        == .init(
          statement: #"DELETE FROM "users" WHERE "id" = ?1"#,
          params: [.string("7B1C1F7C-9C6D-4B48-B6E6-24BCA0B773E1")]
        )
    )
  }
}
