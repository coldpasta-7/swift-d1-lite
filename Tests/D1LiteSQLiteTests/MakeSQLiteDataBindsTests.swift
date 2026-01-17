import D1Lite
import SQLiteNIO
import Testing

@testable import D1LiteSQLite

@Suite struct MakeSQLiteDataBindsTests {
  @Test func test() {
    #expect(
      makeSQLiteDataBinds([
        .number(1),
        .number(1.25),
        .string("hello"),
        .null,
      ]) == [
        .integer(1),
        .float(1.25),
        .text("hello"),
        .null,
      ]
    )
  }
}
