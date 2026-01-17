import Testing

@testable import D1Lite

@Suite struct D1DoubleFormatStyleTests {
  @Test func 相互変換できる() throws {
    let sut = D1DoubleFormatStyle()
    let value = 3.141592

    let actual = try sut.parseStrategy.parse(sut.format(value))

    #expect(actual == value)
  }

  @Test(arguments: [D1Value.null, .string("1")])
  func 数値でなければdecodeに失敗する(d1Value: D1Value) throws {
    let sut = D1DoubleFormatStyle()

    #expect(throws: D1FormatStyle.ParseError.self) {
      _ = try sut.parseStrategy.parse(d1Value)
    }
  }
}
