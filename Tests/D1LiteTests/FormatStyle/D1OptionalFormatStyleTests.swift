import Testing

@testable import D1Lite

@Suite struct D1OptionalFormatStyleTests {
  @Test func nilはnullとしてencodeされる() {
    let sut = D1OptionalFormatStyle(D1StringFormatStyle())

    let actual = sut.format(nil)

    #expect(actual == .null)
  }

  @Test func 値がある場合はencodeされる() {
    let sut = D1OptionalFormatStyle(D1StringFormatStyle())

    let actual = sut.format("Hello, World!")

    #expect(actual == .string("Hello, World!"))
  }

  @Test func nullはnilとしてdecodeされる() throws {
    let sut = D1OptionalFormatStyle(D1StringFormatStyle())

    let actual = try sut.parseStrategy.parse(.null)

    #expect(actual == nil)
  }

  @Test func 値がある場合には変換できる() throws {
    let sut = D1OptionalFormatStyle(D1IntFormatStyle())

    let actual = try sut.parseStrategy.parse(.number(1))

    #expect(actual == 1)
  }

  @Test func 値がありdecode条件に合わなければ失敗する() throws {
    let sut = D1OptionalFormatStyle(D1IntFormatStyle())

    #expect(throws: D1FormatStyle.ParseError.self) {
      _ = try sut.parseStrategy.parse(.string("1"))
    }
  }
}
