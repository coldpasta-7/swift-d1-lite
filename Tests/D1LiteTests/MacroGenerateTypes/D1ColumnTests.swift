import Testing

@testable import D1Lite

@Suite struct D1ColumnTests {
  @Test func parseできる() throws {
    let sut = D1Column(name: "name", formatStyle: D1StringFormatStyle())

    let actual = try sut.parse(d1: .string("Hello"))

    #expect(actual == "Hello")
  }

  @Test func formatでD1Valueに変換できる() {
    let sut = D1Column(name: "count", formatStyle: D1IntFormatStyle())

    let actual = sut.format(value: 2)

    #expect(actual == .number(2))
  }

  @Test func formatAnyで正しい型なら変換できる() {
    let sut = D1Column(name: "name", formatStyle: D1StringFormatStyle())

    let actual = sut.format(any: "World")

    #expect(actual == .string("World"))
  }

  @Test func OptionalのFormatStyleならnullをnilとしてdecodeできる() throws {
    let sut = D1Column(name: "nickname", formatStyle: D1OptionalFormatStyle(D1StringFormatStyle()))

    let actual = try sut.parse(d1: .null)

    #expect(actual == nil)
  }

  @Test func OptionalのFormatStyleならnilをnullとしてencodeできる() {
    let sut = D1Column(name: "nickname", formatStyle: D1OptionalFormatStyle(D1StringFormatStyle()))

    let actual = sut.format(value: nil)

    #expect(actual == .null)
  }
}
