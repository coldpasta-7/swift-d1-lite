import Testing

@testable import D1Lite

@Suite struct D1BoolFormatStyleTests {
  @Test func encodeでtrueが1になる() throws {
    let sut = D1BoolFormatStyle()

    let actual = sut.format(true)

    #expect(actual == .number(1))
  }

  @Test func encodeでfalseが0になる() throws {
    let sut = D1BoolFormatStyle()

    let actual = sut.format(false)

    #expect(actual == .number(0))
  }

  @Test func decodeで1がtrueになる() throws {
    let sut = D1BoolFormatStyle()

    let actual = try sut.parseStrategy.parse(.number(1))

    #expect(actual == true)
  }

  @Test func decodeで0がfalseになる() throws {
    let sut = D1BoolFormatStyle()

    let actual = try sut.parseStrategy.parse(.number(0))

    #expect(actual == false)
  }

  @Test(arguments: [D1Value.number(-1), .number(2), .string(""), .string("1"), .string("0"), .null])
  func `0と1以外のdecodeに失敗する`(d1Value: D1Value) throws {
    let sut = D1BoolFormatStyle()

    #expect(throws: D1FormatStyle.ParseError.self) {
      _ = try sut.parseStrategy.parse(d1Value)
    }
  }
}
