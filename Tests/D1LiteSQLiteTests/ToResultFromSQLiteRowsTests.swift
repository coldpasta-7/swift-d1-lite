import D1Lite
import NIOCore
import SQLiteNIO
import Testing

@testable import D1LiteSQLite

@Suite struct ToResultFromSQLiteRowsTests {
  @Test func emptyRows() {
    let (columns, records) = toResultFromSQLiteDataRows([])
    #expect(columns == [])
    #expect(records == [])
  }

  @Test func singleRow() {
    let buffer = ByteBuffer(bytes: [1, 2, 3])
    let rows: [[(name: String, data: SQLiteData)]] = [
      [
        (name: "id", data: .integer(1)),
        (name: "score", data: .float(1.5)),
        (name: "name", data: .text("alice")),
        (name: "data", data: .blob(buffer)),
        (name: "note", data: .null),
      ]
    ]

    let (columns, records) = toResultFromSQLiteDataRows(rows)

    #expect(columns == ["id", "score", "name", "data", "note"])
    #expect(
      records == [
        [
          "id": .number(1),
          "score": .number(1.5),
          "name": .string("alice"),
          "data": .string("AQID"),
          "note": .null,
        ]
      ]
    )
  }
}
