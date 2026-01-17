import Foundation
import Testing

@testable import D1Lite

@Suite struct D1CodableFormatStyleTests {
  @Test func encodeでJSON文字列になる() throws {
    let sut = D1CodableFormatStyle<Sample>()
    let value = Sample(id: 1, name: "Alice", isActive: true)

    let actual = sut.format(value)

    #expect(actual == .string(#"{"id":1,"isActive":true,"name":"Alice"}"#))
  }

  @Test func decodeでJSON文字列からモデルになる() throws {
    let sut = D1CodableFormatStyle<Sample>()

    let actual = try sut.parseStrategy.parse(.string(#"{"id":2,"name":"Bob","isActive":false}"#))

    #expect(actual == Sample(id: 2, name: "Bob", isActive: false))
  }

  @Test(arguments: [D1Value.null, .number(1)])
  func 文字列以外のdecodeに失敗する(d1Value: D1Value) throws {
    let sut = D1CodableFormatStyle<Sample>()

    #expect(throws: D1FormatStyle.ParseError.self) {
      _ = try sut.parseStrategy.parse(d1Value)
    }
  }

  @Test func JSON形式以外のdecodeに失敗する() throws {
    let sut = D1CodableFormatStyle<Sample>()

    #expect(throws: DecodingError.self) {
      _ = try sut.parseStrategy.parse(.string("not-json"))
    }
  }
}

fileprivate struct Sample: Hashable, Codable {
  let id: Int
  let name: String
  let isActive: Bool
}
