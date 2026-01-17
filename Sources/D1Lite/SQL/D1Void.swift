/// 値を返さないクエリ結果を表す型です.
public final class D1Void: Sendable, Hashable {
  /// 共有インスタンスです.
  public static let shared: D1Void = D1Void()
  private init() {}

  /// 常に等価とみなします.
  public static func == (rhs: D1Void, lhs: D1Void) -> Bool { true }
  /// ハッシュ値を生成します.
  public func hash(into hasher: inout Hasher) {}
}

extension D1Void: D1RecordsDecodable {
  /// 複数レコードから復元します.
  public static func decode(d1Records: [[String: D1Value]]) throws -> D1Void {
    .shared
  }
}
