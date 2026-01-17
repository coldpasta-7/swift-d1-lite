public import Configuration
public import D1Lite
import Foundation
import SQLiteNIO
public import SystemPackage

/// ローカルの SQLite またはメモリ上で実行します.
public actor SQLiteD1RawDatabaseQueryClient: D1RawDatabaseQueryClient {
  /// 設定.
  private let config: Configuration
  private var connection: SQLiteConnection?

  /// バッチで raw クエリを実行します.
  /// - Parameter statements: 実行する SQL 文の配列.
  /// - Returns: クエリ結果の配列.
  /// - Throws: 通信エラーや API エラーが発生した場合.
  public func batch(statements: [D1Statement]) async throws -> [D1QueryResult] {
    if statements.isEmpty {
      return []
    }
    let connection = try await openConnectionIfNeeded()
    var results: [D1QueryResult] = []
    results.reserveCapacity(statements.count)
    if statements.count > 1 {
      do {
        _ = try await connection.query("BEGIN")
      } catch {
        throw toD1RawDatabaseQueryClientErrorFromError(error)
      }
    }
    do {
      for statement in statements {
        let result = try await execute(statement: statement, connection: connection)
        results.append(result)
      }
      if statements.count > 1 {
        _ = try await connection.query("COMMIT")
      }
    } catch {
      if statements.count > 1 {
        _ = try? await connection.query("ROLLBACK")
      }
      throw toD1RawDatabaseQueryClientErrorFromError(error)
    }
    return results
  }

  /// `SQLiteD1RawDatabaseQueryClient` の設定です.
  public enum Configuration: Sendable, Hashable {
    /// メモリ上で動作させる.
    case inMemory
    /// 指定された `FilePath` を SQLite データとして動作させる.
    case file(FilePath)
  }

  /// SQLite 実行時のエラーです.
  public enum SQLiteError: Error, Sendable, Hashable {
    case columnNotFound(String)
  }

  /// 初期化します.
  /// - Parameter config: 設定.
  public init(config: Configuration) {
    self.config = config
  }

  /// コネクションを閉じます.
  public func shutdown() async throws {
    guard let connection else { return }
    try await connection.close()
    self.connection = nil
  }

  /// Configuration ライブラリから初期化します.
  /// - Parameter configReader: 設定読み取り器.
  /// - Throws: `d1.inmemory` の設定がないか false であり、`d1.sqlite.file.path` が指定されていない場合にエラーが投げられます.
  public init(configReader: ConfigReader) throws {
    if configReader.bool(forKey: "d1.inmemory", default: false) {
      self.init(config: .inMemory)
      return
    }

    let filePath = try configReader.requiredString(forKey: "d1.sqlite.file.path")
    self.init(config: .file(FilePath(filePath)))
  }

  private func openConnectionIfNeeded() async throws -> SQLiteConnection {
    if let connection { return connection }

    do {
      let connection = try await SQLiteConnection.open(storage: storage)
      self.connection = connection
      return connection
    } catch {
      throw toD1RawDatabaseQueryClientErrorFromError(error)
    }
  }

  private var storage: SQLiteConnection.Storage {
    switch config {
    case .inMemory: .memory
    case .file(let path): .file(path: path.string)
    }
  }

  private func execute(statement: D1Statement, connection: SQLiteConnection) async throws -> D1QueryResult {
    let start = Date()
    let rows = try await connection.query(statement.sql, makeSQLiteDataBinds(statement.params))
    let (columns, records) = toResultFromSQLiteDataRows(
      rows.map { row in
        row.columns.map { (name: $0.name, data: $0.data) }
      }
    )
    let duration = Date().timeIntervalSince(start)
    var meta = D1QueryResult.Meta(duration: duration)

    meta.rowsRead = records.count
    let changes = try await fetchChanges(connection: connection)
    let lastRowID = try await connection.lastAutoincrementID()
    meta.changedDB = changes > 0
    meta.changes = changes
    meta.lastRowID = lastRowID == 0 ? nil : lastRowID
    meta.rowsWritten = changes

    return D1QueryResult(meta: meta, columns: columns, records: records)
  }

  private func fetchChanges(connection: SQLiteConnection) async throws -> Int {
    let rows = try await connection.query("SELECT changes() AS changes")
    guard let row = rows.first, let data = row.column("changes") else {
      throw SQLiteError.columnNotFound("changes")
    }
    return switch data {
    case .integer(let value): value
    case .float(let value): Int(value)
    case .text(let value): Int(value) ?? 0
    case .blob, .null: 0
    }
  }
}
