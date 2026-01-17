public import Foundation

/// D1 の raw クエリを実行するためのクライアントです.
public protocol D1RawDatabaseQueryClient: Sendable {
  /// 複数の SQL 文をまとめて実行し、結果を返します.
  /// - Parameter statements: 実行する SQL 文の配列.
  /// - Returns: クエリ結果の配列.
  /// - Throws: 通信エラーや API エラーが発生した場合.
  func batch(statements: [D1Statement]) async throws -> [D1QueryResult]
}

/// D1 の raw クエリ実行で発生したエラー情報です.
public struct D1RawDatabaseQueryClientError: Error, Sendable, Hashable, Codable {
  /// API が返したエラー情報の一覧です.
  public var errors: [D1ResponseInfo]
  /// API が返したメッセージの一覧です.
  public var messages: [D1ResponseInfo]

  /// エラー情報とメッセージを指定して作成します.
  /// - Parameters:
  ///   - errors: エラー情報.
  ///   - messages: メッセージ情報.
  public init(errors: [D1ResponseInfo], messages: [D1ResponseInfo]) {
    self.errors = errors
    self.messages = messages
  }
}

/// API のレスポンスに含まれる情報項目です.
public struct D1ResponseInfo: Sendable, Hashable, Codable {
  /// 応答コードです.
  public var code: Int
  /// 応答メッセージです.
  public var message: String
  /// 関連するドキュメントの URL です.
  public var documentationURL: String?
  /// エラー発生箇所の補足情報です.
  public var source: Source?

  /// 応答情報を指定して作成します.
  /// - Parameters:
  ///   - code: 応答コード.
  ///   - message: 応答メッセージ.
  ///   - documentationURL: 関連ドキュメントの URL.
  ///   - source: 補足情報.
  public init(code: Int, message: String, documentationURL: String? = nil, source: Source? = nil) {
    self.code = code
    self.message = message
    self.documentationURL = documentationURL
    self.source = source
  }

  enum CodingKeys: String, CodingKey {
    case code
    case message
    case documentationURL = "documentation_url"
    case source
  }

  /// エラーの発生箇所を示す情報です.
  public struct Source: Sendable, Hashable, Codable {
    /// エラー箇所の JSON ポインタです.
    public var pointer: String?

    /// エラーの発生箇所を指定して作成します.
    /// - Parameter pointer: エラー箇所の JSON ポインタ.
    public init(pointer: String? = nil) {
      self.pointer = pointer
    }
  }
}

/// raw クエリの結果を表します.
public struct D1QueryResult: Sendable, Hashable, Codable {
  /// クエリ実行に関するメタ情報です.
  public var meta: Meta
  /// 取得したカラム名の一覧です.
  public var columns: [String]
  /// 取得したレコードの一覧です.
  public var records: [[String: D1Value]]

  /// クエリ結果を指定して作成します.
  /// - Parameters:
  ///   - meta: メタ情報.
  ///   - columns: カラム名の一覧.
  ///   - records: レコードの一覧.
  public init(meta: Meta, columns: [String], records: [[String: D1Value]]) {
    self.meta = meta
    self.columns = columns
    self.records = records
  }

  /// クエリ実行に関するメタ情報です.
  public struct Meta: Sendable, Hashable, Codable {
    /// データベースに変更があったかどうかを示します.
    public var changedDB: Bool?
    /// 変更された行数の目安です.
    public var changes: Int?
    /// SQL 実行時間（秒）です.
    public var duration: TimeInterval?
    /// 最後に挿入された行の ID です.
    public var lastRowID: Int?
    /// 読み取った行数です.
    public var rowsRead: Int?
    /// 書き込んだ行数です.
    public var rowsWritten: Int?
    /// プライマリで処理されたかどうかを示します.
    public var servedByPrimary: Bool?
    /// 処理したリージョンを示します.
    public var servedByRegion: Region?
    /// コミット後の DB サイズ（バイト）です.
    public var sizeAfter: Int?
    /// 実行時間の内訳です.
    public var timings: Timings?

    /// メタ情報を指定して作成します.
    /// - Parameters:
    ///   - changedDB: DB に変更があったかどうか.
    ///   - changes: 変更された行数の目安.
    ///   - duration: SQL 実行時間（秒）.
    ///   - lastRowID: 最後に挿入された行 ID.
    ///   - rowsRead: 読み取った行数.
    ///   - rowsWritten: 書き込んだ行数.
    ///   - servedByPrimary: プライマリで処理されたかどうか.
    ///   - servedByRegion: 処理したリージョン.
    ///   - sizeAfter: コミット後の DB サイズ（バイト）.
    ///   - timings: 実行時間の内訳.
    public init(
      changedDB: Bool? = nil,
      changes: Int? = nil,
      duration: TimeInterval? = nil,
      lastRowID: Int? = nil,
      rowsRead: Int? = nil,
      rowsWritten: Int? = nil,
      servedByPrimary: Bool? = nil,
      servedByRegion: Region? = nil,
      sizeAfter: Int? = nil,
      timings: Timings? = nil,
    ) {
      self.changedDB = changedDB
      self.changes = changes
      self.duration = duration
      self.lastRowID = lastRowID
      self.rowsRead = rowsRead
      self.rowsWritten = rowsWritten
      self.servedByPrimary = servedByPrimary
      self.servedByRegion = servedByRegion
      self.sizeAfter = sizeAfter
      self.timings = timings
    }

    /// クエリ実行時間の内訳です.
    public struct Timings: Sendable, Hashable, Codable {
      /// SQL 実行時間（ミリ秒）です.
      public var sqlDurationMs: Double?

      /// 実行時間の内訳を指定して作成します.
      /// - Parameter sqlDurationMs: SQL 実行時間（ミリ秒）.
      public init(sqlDurationMs: Double? = nil) {
        self.sqlDurationMs = sqlDurationMs
      }

      enum CodingKeys: String, CodingKey {
        case sqlDurationMs = "sql_duration_ms"
      }
    }

    /// クエリを処理したリージョンです.
    public enum Region: String, Sendable, Hashable, Codable {
      /// 北米西部.
      case westernNorthAmerica = "WNAM"
      /// 北米東部.
      case easternNorthAmerica = "ENAM"
      /// 西ヨーロッパ.
      case westernEurope = "WEUR"
      /// 東ヨーロッパ.
      case easternEurope = "EEUR"
      /// アジア太平洋.
      case asiaPacific = "APAC"
      /// オセアニア.
      case oceania = "OC"
    }

    enum CodingKeys: String, CodingKey {
      case changedDB = "changed_db"
      case changes
      case duration
      case lastRowID = "last_row_id"
      case rowsRead = "rows_read"
      case rowsWritten = "rows_written"
      case servedByPrimary = "served_by_primary"
      case servedByRegion = "served_by_region"
      case sizeAfter = "size_after"
      case timings
    }
  }
}
