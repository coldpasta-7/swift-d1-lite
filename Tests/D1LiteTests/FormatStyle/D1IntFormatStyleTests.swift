import Testing

@testable import D1Lite

@Suite struct D1IntFormatStyleTests {
  @Test func 相互変換できる() throws {
    let sut = D1IntFormatStyle()
    let int = 1

    let actual = try sut.parseStrategy.parse(sut.format(int))

    #expect(actual == int)
  }

  @Test(arguments: [D1Value.null, .string("1")])
  func 数値でなければdecodeに失敗する(d1Value: D1Value) throws {
    let sut = D1IntFormatStyle()

    #expect(throws: D1FormatStyle.ParseError.self) {
      _ = try sut.parseStrategy.parse(d1Value)
    }
  }

  @Test func 整数でなければdecodeに失敗する() throws {
    let sut = D1IntFormatStyle()

    #expect(throws: D1FormatStyle.ParseError.self) {
      _ = try sut.parseStrategy.parse(.number(3.14))
    }
  }
}
