import D1Lite
import Foundation
import Testing

@Suite struct D1ValueTests {
  @Suite struct Codableに準拠している {
    @Test(arguments: [
      (json: #"0"#, expected: D1Value.number(0)),
      (json: #"1"#, expected: D1Value.number(1)),
      (json: #"3.14"#, expected: D1Value.number(3.14)),
      (json: #"-1"#, expected: D1Value.number(-1)),
      (json: #"-3.14"#, expected: D1Value.number(-3.14)),
      (json: #""Hello, World!""#, expected: D1Value.string("Hello, World!")),
      (json: #""""#, expected: D1Value.string("")),
      (json: #"null"#, expected: D1Value.null),
      (json: #""NULL""#, expected: D1Value.string("NULL")),
    ])
    func decode(json: String, expected: D1Value) throws {
      let decoder = JSONDecoder()
      let data = try #require(json.data(using: .utf8))

      let actual = try decoder.decode(D1Value.self, from: data)

      #expect(actual == expected)
    }

    @Test(arguments: [
      (d1: D1Value.number(0), expected: #"0"#),
      (d1: D1Value.number(1), expected: #"1"#),
      (d1: D1Value.number(3.14), expected: #"3.14"#),
      (d1: D1Value.number(-1), expected: #"-1"#),
      (d1: D1Value.number(-3.14), expected: #"-3.14"#),
      (d1: D1Value.string("Hello, World!"), expected: #""Hello, World!""#),
      (d1: D1Value.string(""), expected: #""""#),
      (d1: D1Value.string("NULL"), expected: #""NULL""#),
      (d1: D1Value.null, expected: #"null"#),
    ])
    func encode(d1: D1Value, expected: String) throws {
      let encoder = JSONEncoder()
      let data = try encoder.encode(d1)

      let actual = try #require(String(data: data, encoding: .utf8))

      #expect(actual == expected)
    }
  }
}
