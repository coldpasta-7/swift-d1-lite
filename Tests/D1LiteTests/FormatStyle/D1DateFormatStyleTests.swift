import Foundation
import Testing

@testable import D1Lite

@Suite struct D1DateFormatStyleTests {
  @Test func `yyyy-MM-ddをencode/decodeできる`() throws {
    let sut = D1DateFormatStyle(format: .yyyyMMdd)
    let date = try Date.ISO8601FormatStyle().parse("2024-01-02T00:00:00Z")

    let actual = try sut.parseStrategy.parse(sut.format(date))

    #expect(actual == date)
  }

  @Test func `epochをencode/decodeできる`() throws {
    let sut = D1DateFormatStyle(format: .epoch)
    let date = try Date.ISO8601FormatStyle().parse("2006-01-02T03:04:05Z")

    let actual = try sut.parseStrategy.parse(sut.format(date))

    #expect(actual == date)
  }

  @Test func `formatで指定したiso8601フォーマットに委譲する`() throws {
    let sut = D1DateFormatStyle(format: .iso8601)
    let date = try Date.ISO8601FormatStyle().parse("2006-01-02T03:04:05Z")

    let actual = try sut.parseStrategy.parse(sut.format(date))

    #expect(actual == date)
  }
}
