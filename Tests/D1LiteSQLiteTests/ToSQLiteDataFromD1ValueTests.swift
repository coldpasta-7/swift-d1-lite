import D1Lite
import NIOCore
import SQLiteNIO
import Testing

@testable import D1LiteSQLite

@Suite struct ToSQLiteDataFromD1ValueTests {
  @Test(arguments: [
    (data: SQLiteData.integer(2), expected: D1Value.number(2)),
    (data: SQLiteData.float(2.5), expected: D1Value.number(2.5)),
    (data: SQLiteData.text("text"), expected: D1Value.string("text")),
    (data: SQLiteData.null, expected: D1Value.null),
  ])
  func map(data: SQLiteData, expected: D1Value) {
    #expect(toSQLiteDataFromD1Value(data) == expected)
  }

  @Test func blobToBase64() {
    let buffer = ByteBuffer(bytes: [1, 2, 3])

    let actual = toSQLiteDataFromD1Value(.blob(buffer))

    #expect(actual == .string("AQID"))
  }
}
