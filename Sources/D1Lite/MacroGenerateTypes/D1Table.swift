/// D1 テーブルを表すマーカー用プロトコル.
public protocol D1Table: Sendable, Hashable, D1Decodable {
  /// テーブル名.
  static var schema: String { get }
  /// テーブルに含まれる全てのカラム名の配列.
  static var allColumnNames: [String] { get }
  /// 全てのカラム値を``D1Value``として変換した配列.
  var allD1Values: [D1Value] { get }

  /// 指定されたプロパティのFormatStyleで値をD1Valueに変換する.
  static func d1Format<Value: Sendable>(_ keyPath: KeyPath<Self, Value>, value: Value) -> D1Value
  /// 指定されたプロパティのカラム名を取得する.
  static func d1ColumnName<Value: Sendable>(_ keyPath: KeyPath<Self, Value>) -> String
}
