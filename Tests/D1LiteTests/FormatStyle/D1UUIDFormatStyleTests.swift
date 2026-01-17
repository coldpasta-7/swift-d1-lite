import Foundation
import Testing

@testable import D1Lite

@Suite struct D1UUIDFormatStyleTests {
  @Test func encodeでUUID文字列になる() throws {
    let sut = D1UUIDFormatStyle()

    let actual = sut.format(try #require(UUID(uuidString: "7B1C1F7C-9C6D-4B48-B6E6-24BCA0B773E1")))

    #expect(actual == .string("7B1C1F7C-9C6D-4B48-B6E6-24BCA0B773E1"))
  }

  @Test func decodeでUUID文字列からUUIDになる() throws {
    let sut = D1UUIDFormatStyle()

    let actual = try sut.parseStrategy.parse(.string("7B1C1F7C-9C6D-4B48-B6E6-24BCA0B773E1"))

    #expect(actual == (try #require(UUID(uuidString: "7B1C1F7C-9C6D-4B48-B6E6-24BCA0B773E1"))))
  }

  @Test(arguments: [D1Value.null, .number(1)])
  func 文字列以外のdecodeに失敗する(d1Value: D1Value) throws {
    let sut = D1UUIDFormatStyle()

    #expect(throws: D1FormatStyle.ParseError.self) {
      _ = try sut.parseStrategy.parse(d1Value)
    }
  }

  @Test func UUID形式以外のdecodeに失敗する() throws {
    let sut = D1UUIDFormatStyle()

    #expect(throws: D1FormatStyle.ParseError.self) {
      _ = try sut.parseStrategy.parse(.string("not-a-uuid"))
    }
  }
}
