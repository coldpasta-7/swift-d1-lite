public import AsyncHTTPClient
public import Configuration
public import D1Lite
public import Foundation
import NIOCore

/// AsyncHTTPClient を使って D1 の raw クエリを実行するクライアントです.
public struct AsyncHTTPD1RawDatabaseQueryClient: D1RawDatabaseQueryClient, Sendable {
  /// クライアントの設定情報です.
  public struct Configuration: Sendable, Hashable {
    /// API のベース URL です.
    public var baseURL: URL
    /// Cloudflare アカウント ID です.
    public var accountID: String
    /// D1 データベース ID です.
    public var databaseID: String
    /// API トークンです.
    public var apiToken: String
    /// リクエストのタイムアウト（秒）です.
    public var timeout: TimeInterval
    /// レスポンスの最大バイト数です.
    public var maxResponseBytes: Int

    /// デフォルトのベース URL です.
    public static let defaultBaseURL: URL = URL(string: "https://api.cloudflare.com/client/v4")!
    /// デフォルトのタイムアウト（秒）です.
    public static let defaultTimeout: TimeInterval = 30
    /// デフォルトの最大レスポンスバイト数です.
    public static let defaultMaxResponseBytes: Int = 10 * 1024 * 1024

    /// 設定情報を指定して作成します.
    /// - Parameters:
    ///   - baseURL: API のベース URL.
    ///   - accountID: Cloudflare アカウント ID.
    ///   - databaseID: D1 データベース ID.
    ///   - apiToken: API トークン.
    ///   - timeout: リクエストのタイムアウト（秒）.
    ///   - maxResponseBytes: レスポンスの最大バイト数.
    public init(
      baseURL: URL = Self.defaultBaseURL,
      accountID: String,
      databaseID: String,
      apiToken: String,
      timeout: TimeInterval = Self.defaultTimeout,
      maxResponseBytes: Int = Self.defaultMaxResponseBytes,
    ) {
      self.baseURL = baseURL
      self.accountID = accountID
      self.databaseID = databaseID
      self.apiToken = apiToken
      self.timeout = timeout
      self.maxResponseBytes = maxResponseBytes
    }

    /// 設定リーダーから作成します.
    public init(configReader: ConfigReader) throws {
      self.init(
        baseURL: configReader.string(forKey: "d1.base.url").flatMap(URL.init(string:)) ?? Self.defaultBaseURL,
        accountID: try configReader.requiredString(forKey: "d1.account.id"),
        databaseID: try configReader.requiredString(forKey: "d1.database.id"),
        apiToken: try configReader.requiredString(forKey: "d1.api.token", isSecret: true),
        timeout: configReader.double(forKey: "d1.http.request.timeout.sec", default: Self.defaultTimeout),
        maxResponseBytes: configReader.int(
          forKey: "d1.http.request.response.max.bytes",
          default: Self.defaultMaxResponseBytes,
        ),
      )
    }
  }

  /// 設定読み込み時のエラーです.
  public enum ConfigReadError: Error, Sendable, Hashable {
    case invalidBaseURL(String)
    case accountIDNotFound
  }

  /// リクエスト送信に利用する HTTP クライアントです.
  public var httpClient: HTTPClient
  /// クライアントの設定です.
  public var configuration: Configuration

  /// HTTP クライアントと設定を指定して作成します.
  /// - Parameters:
  ///   - httpClient: HTTP クライアント.
  ///   - configuration: クライアント設定.
  public init(httpClient: HTTPClient, configuration: Configuration) {
    self.httpClient = httpClient
    self.configuration = configuration
  }

  /// HTTP クライアントと設定リーダーを指定して作成します.
  public init(httpClient: HTTPClient, configReader: ConfigReader) throws {
    self.init(httpClient: httpClient, configuration: try .init(configReader: configReader))
  }

  /// バッチで raw クエリを実行します.
  /// - Parameter statements: 実行する SQL 文の配列.
  /// - Returns: クエリ結果の配列.
  /// - Throws: 通信エラーや API エラーが発生した場合.
  public func batch(statements: [D1Statement]) async throws -> [D1QueryResult] {
    let request = try makeRequest(statements: statements)

    let response = try await httpClient.execute(request, timeout: timeout)

    let buffer = try await response.body.collect(upTo: configuration.maxResponseBytes)

    let content = try JSONDecoder().decode(RawBatchResponse.self, from: Data(buffer: buffer))
    guard content.success else {
      throw D1RawDatabaseQueryClientError(errors: content.errors, messages: content.messages)
    }
    return content.result.map { content in
      let columns = content.results?.columns ?? []
      let rows = content.results?.rows ?? []
      let records =
        rows
        .map { row in zip(columns, row) }
        .map(Dictionary.init(uniqueKeysWithValues:))

      return D1QueryResult(
        meta: content.meta ?? .init(),
        columns: columns,
        records: records,
      )
    }
  }
}

extension AsyncHTTPD1RawDatabaseQueryClient {
  func makeRequest(statements: [D1Statement]) throws -> HTTPClientRequest {
    let bodyData = try JSONEncoder().encode(RawBatchRequest(batch: statements))
    var request = HTTPClientRequest(url: url.absoluteString)
    request.method = .POST
    request.headers.add(name: "Content-Type", value: "application/json")
    request.headers.add(name: "Authorization", value: "Bearer \(configuration.apiToken)")
    request.body = .bytes(ByteBuffer(data: bodyData))
    return request
  }

  var url: URL {
    var url = configuration.baseURL
    url.appendPathComponent("accounts")
    url.appendPathComponent(configuration.accountID)
    url.appendPathComponent("d1")
    url.appendPathComponent("database")
    url.appendPathComponent(configuration.databaseID)
    url.appendPathComponent("raw")
    return url
  }

  var timeout: TimeAmount {
    TimeAmount.nanoseconds(Int64(configuration.timeout * 1_000_000_000))
  }
}

fileprivate struct RawBatchRequest: Sendable, Encodable {
  let batch: [D1Statement]
}

fileprivate struct RawBatchResponse: Sendable, Decodable {
  let errors: [D1ResponseInfo]
  let messages: [D1ResponseInfo]
  let result: [RawQueryResult]
  let success: Bool
}

fileprivate struct RawQueryResult: Sendable, Decodable {
  let meta: D1QueryResult.Meta?
  let results: RawResults?
  let success: Bool?
}

fileprivate struct RawResults: Sendable, Decodable {
  let columns: [String]?
  let rows: [[D1Value]]?
}
