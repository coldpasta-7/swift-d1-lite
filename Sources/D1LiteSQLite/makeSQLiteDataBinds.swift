import D1Lite
import SQLiteNIO

/// D1 の値を SQLite のバインド値に変換します.
/// - Parameter params: D1 の値の配列.
/// - Returns: SQLite へ渡すバインド値の配列.
///
/// 数値は整数かつ Int の範囲内であれば `.integer`、それ以外は `.float` として扱います.
func makeSQLiteDataBinds(_ params: [D1Value]) -> [SQLiteData] {
  params.map { value in
    switch value {
    case .number(let number):
      if number.rounded() == number,
        number >= Double(Int.min),
        number <= Double(Int.max)
      {
        .integer(Int(number))
      } else {
        .float(number)
      }
    case .string(let string): .text(string)
    case .null: .null
    }
  }
}
