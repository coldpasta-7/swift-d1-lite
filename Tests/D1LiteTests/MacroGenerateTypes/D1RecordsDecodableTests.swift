import Testing

@testable import D1Lite

@Suite struct D1RecordsDecodableTests {
  enum TestError: Error {
    case invalidRecord
  }

  struct NumberRow: D1Decodable, Hashable {
    let value: Int

    static func decode(d1 record: [String: D1Value]) throws -> NumberRow {
      guard case .number(let number) = record["value"] else {
        throw D1TableDecodingError.missingValue(property: "value", column: "value")
      }
      return NumberRow(value: Int(number))
    }
  }

  @Test func Arrayで複数レコードを復元できる() throws {
    let records: [[String: D1Value]] = [
      ["value": .number(1)],
      ["value": .number(2)],
      ["value": .number(3)],
    ]

    let actual = try [NumberRow].decode(d1Records: records)

    #expect(
      actual == [.init(value: 1), .init(value: 2), .init(value: 3)]
    )
  }

  @Test func Setで複数レコードを復元できる() throws {
    let records: [[String: D1Value]] = [
      ["value": .number(1)],
      ["value": .number(2)],
      ["value": .number(1)],
    ]

    let actual = try Set<NumberRow>.decode(d1Records: records)

    #expect(
      actual == [
        NumberRow(value: 1),
        NumberRow(value: 2),
      ]
    )
  }

  @Suite struct OptionalTests {
    @Test func Optionalで先頭レコードを復元できる() throws {
      let records: [[String: D1Value]] = [["value": .number(10)], ["value": .number(20)]]

      let actual = try Optional<NumberRow>.decode(d1Records: records)

      #expect(actual == NumberRow(value: 10))
    }

    @Test func Optionalで空配列ならnilになる() throws {
      let records: [[String: D1Value]] = []

      let actual = try Optional<NumberRow>.decode(d1Records: records)

      #expect(actual == nil)
    }
  }
}
