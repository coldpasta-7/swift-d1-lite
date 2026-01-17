import Logging
import NIOCore
import NIOEmbedded
import SQLKit
import SQLiteKit
import Synchronization

final class D1SQLDatabase: Sendable, SQLDatabase {
  let logger: Logger = .init(label: "D1SQLDatabase")
  let eventLoop: any EventLoop = NIOEmbedded.EmbeddedEventLoop()
  let dialect: any SQLDialect = SQLiteDialect()

  let statementMutex: Mutex<D1Statement?> = .init(nil)

  func execute(sql query: any SQLExpression, _ onRow: @escaping (any SQLRow) -> Void) -> EventLoopFuture<Void> {
    var serializer = SQLSerializer(database: self)
    query.serialize(to: &serializer)
    let statement = D1Statement(sql: serializer.sql, params: serializer.binds.compactMap { $0 as? D1Value })
    statementMutex.withLock { $0 = statement }
    return eventLoop.makeSucceededVoidFuture()
  }

  var statement: D1Statement? {
    statementMutex.withLock({ $0 })
  }
}
