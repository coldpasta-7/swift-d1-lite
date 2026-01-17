import Testing

@testable import D1Lite

@Suite struct D1StringFormatStyleTests {
  @Test func 相互変換できる() throws {
    let sut = D1StringFormatStyle()
    let string = "Hello, World!"

    let actual = try sut.parseStrategy.parse(sut.format(string))

    #expect(actual == string)
  }

  @Test(arguments: [D1Value.null, .number(1)])
  func 文字列でなければdecodeに失敗する(d1Value: D1Value) throws {
    let sut = D1StringFormatStyle()

    #expect(throws: D1FormatStyle.ParseError.self) {
      try sut.parseStrategy.parse(d1Value)
    }
  }
}
