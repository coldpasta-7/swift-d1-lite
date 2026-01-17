import Foundation
import Testing

@testable import D1Lite

@Suite struct D1DataFormatStyleTests {
  @Test func encodeでBase64文字列になる() throws {
    let sut = D1DataFormatStyle()
    let value = Data("Hello".utf8)

    let actual = sut.format(value)

    #expect(actual == .string("SGVsbG8="))
  }

  @Test func decodeでBase64文字列からDataになる() throws {
    let sut = D1DataFormatStyle()

    let actual = try sut.parseStrategy.parse(.string("SGVsbG8="))

    #expect(actual == Data("Hello".utf8))
  }

  @Test(arguments: [D1Value.null, .number(1)])
  func 文字列以外のdecodeに失敗する(d1Value: D1Value) throws {
    let sut = D1DataFormatStyle()

    #expect(throws: D1FormatStyle.ParseError.self) {
      _ = try sut.parseStrategy.parse(d1Value)
    }
  }

  @Test func Base64形式以外のdecodeに失敗する() throws {
    let sut = D1DataFormatStyle()

    #expect(throws: D1FormatStyle.ParseError.self) {
      _ = try sut.parseStrategy.parse(.string("invalid-base64"))
    }
  }
}
