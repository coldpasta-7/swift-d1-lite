import Foundation
import Testing

@testable import D1Lite

@Suite struct D1DateEpochFormatStyleTests {
  @Test func encodeでエポック秒になる() throws {
    let sut = D1DateEpochFormatStyle()
    let date = Date(timeIntervalSince1970: 1_700_000_000.5)

    let actual = sut.format(date)

    #expect(actual == .number(1_700_000_000.5))
  }

  @Test func decodeで日付になる() throws {
    let sut = D1DateEpochFormatStyle()

    let actual = try sut.parseStrategy.parse(.number(1_700_000_000.5))

    #expect(actual == Date(timeIntervalSince1970: 1_700_000_000.5))
  }

  @Test(arguments: [D1Value.null, .string("1")])
  func 数値以外のdecodeに失敗する(d1Value: D1Value) throws {
    let sut = D1DateEpochFormatStyle()

    #expect(throws: D1FormatStyle.ParseError.self) {
      _ = try sut.parseStrategy.parse(d1Value)
    }
  }
}
