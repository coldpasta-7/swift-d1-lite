import D1Lite
import Foundation
import Logging
import Testing

@Suite struct D1UpdateTests {
  @Test func 更新Queryを作成できる() async throws {
    // Arrange
    let uuid = try #require(UUID(uuidString: "7B1C1F7C-9C6D-4B48-B6E6-24BCA0B773E1"))

    // Act
    let actual = User.update()
      .filter(\.id == uuid)
      .set(\.name, "Bob")
      .build()

    // Assert
    #expect(
      actual
        == .init(
          statement: #"UPDATE "users" SET "name" = ?1 WHERE "id" = ?2"#,
          params: [.string("Bob"), .string("7B1C1F7C-9C6D-4B48-B6E6-24BCA0B773E1")]
        )
    )
  }
}
