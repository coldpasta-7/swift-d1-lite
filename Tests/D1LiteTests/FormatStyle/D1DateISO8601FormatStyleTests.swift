import Foundation
import Testing

@testable import D1Lite

@Suite struct D1DateISO8601FormatStyleTests {
  @Test func encodeで秒までの文字列になる() throws {
    let sut = D1DateISO8601FormatStyle()
    let date = try Date.ISO8601FormatStyle().parse("2006-01-02T03:04:05Z")

    let actual = sut.format(date)

    #expect(actual == .string("2006-01-02T03:04:05Z"))
  }

  @Test func decodeで日付になる() throws {
    let sut = D1DateISO8601FormatStyle()

    let actual = try sut.parseStrategy.parse(.string("2006-01-02T03:04:05Z"))

    #expect(actual == (try Date.ISO8601FormatStyle().parse("2006-01-02T03:04:05Z")))
  }

  @Test(arguments: [D1Value.null, .number(1)])
  func 文字列以外のdecodeに失敗する(d1Value: D1Value) throws {
    let sut = D1DateISO8601FormatStyle()

    #expect(throws: D1FormatStyle.ParseError.self) {
      _ = try sut.parseStrategy.parse(d1Value)
    }
  }
}
