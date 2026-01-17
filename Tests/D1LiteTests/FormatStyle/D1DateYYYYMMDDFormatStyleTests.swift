import Foundation
import Testing

@testable import D1Lite

@Suite struct D1DateYYYYMMDDFormatStyleTests {
  @Test func `encodeでyyyy-MM-dd形式の文字列になる`() throws {
    let sut = D1DateYYYYMMDDFormatStyle()

    let actual = sut.format(try Date.ISO8601FormatStyle().parse("2024-01-02T00:00:00Z"))

    #expect(actual == .string("2024-01-02"))
  }

  @Test func decodeで日付になる() throws {
    let sut = D1DateYYYYMMDDFormatStyle()

    let actual = try sut.parseStrategy.parse(.string("2024-01-02"))

    #expect(actual == (try Date.ISO8601FormatStyle().parse("2024-01-02T00:00:00Z")))
  }

  @Test func 不正な文字列のdecodeに失敗する() throws {
    let sut = D1DateYYYYMMDDFormatStyle()

    #expect(throws: (any Error).self) {
      _ = try sut.parseStrategy.parse(.string("2024/01/02"))
    }
  }

  @Test(arguments: [D1Value.null, .number(1)])
  func 文字列以外ではdecodeに失敗する(d1Value: D1Value) throws {
    let sut = D1DateYYYYMMDDFormatStyle()

    #expect(throws: D1FormatStyle.ParseError.self) {
      _ = try sut.parseStrategy.parse(d1Value)
    }
  }
}
