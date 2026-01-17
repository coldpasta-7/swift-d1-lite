/// D1 テーブルのデコード時に発生するエラーです.
public enum D1TableDecodingError: Error, Sendable, Hashable {
  /// レコードに必要なカラムが存在しない場合のエラーです.
  case missingValue(property: String, column: String)
}
