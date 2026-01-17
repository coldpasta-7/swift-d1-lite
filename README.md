# Swift D1 ORM (swift-d1-lite)

Cloudflare D1 を ReadModel として扱うための軽量 ORM です。Swift から D1 の raw
クエリを実行し、マクロによるテーブル定義やフォーマットスタイルによる型変換を提供します。

## 特徴

- `@D1Table` / `@D1Column` によるテーブル定義の簡略化
- `D1SQLClient` によるバッチ実行
- `D1FormatStyle` による型安全な変換
- HTTP 経由の実行（`D1LiteAsyncHTTPClient`）と SQLite
  実行（`D1LiteSQLite`）を提供

## 対象

- Cloudflare D1 を Swift から型安全に扱いたい方
- CQRS/ES の ReadModel を軽量に実装したい方
- テストや開発時にローカルで D1 相当の動作を再現したい方

## インストール

Swift Package Manager で追加できます。

```swift
.package(url: "https://github.com/lemo-nade-room/swift-d1-lite.git", from: "0.1.0")
```

利用するターゲットに応じて依存関係を追加してください。

```swift
.target(
  name: "YourTarget",
  dependencies: [
    .product(name: "D1Lite", package: "swift-d1-lite"),
    // HTTP 経由で D1 を実行する場合
    .product(name: "D1LiteAsyncHTTPClient", package: "swift-d1-lite"),
    // ローカル SQLite で実行する場合
    .product(name: "D1LiteSQLite", package: "swift-d1-lite"),
  ]
)
```

## 使い方（D1Lite）

```swift
import D1Lite
import Foundation

@D1Table(schema: "users")
struct User: Sendable {
  @D1Column
  var id: UUID

  @D1Column
  var name: String

  @D1Column(name: "created_at", formatStyle: D1DateFormatStyle(format: .epoch))
  var createdAt: Date
}

let client = D1SQLClient(client: rawClient)
let userID = UUID()
let user = User(id: userID, name: "Alice", createdAt: Date())

let (insertResult, fetched) = try await client.batch(
  user.create(),
  User.select().filter(\.id == userID).first()
)
```

## 使い方（D1LiteAsyncHTTPClient）

```swift
import AsyncHTTPClient
import Configuration
import D1Lite
import D1LiteAsyncHTTPClient
import Foundation

let config = ConfigReader(providers: [
  EnvironmentVariablesProvider(),
])

let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
let rawClient = try AsyncHTTPD1RawDatabaseQueryClient(httpClient: httpClient, configReader: config)
let client = D1SQLClient(client: rawClient)

let userID = UUID()
let result = try await client.batch(
  User.select().filter(\.id == userID).first()
)
```

## 使い方（D1LiteSQLite）

```swift
import D1Lite
import D1LiteSQLite
import Foundation

let rawClient = SQLiteD1RawDatabaseQueryClient(config: .inMemory)
let client = D1SQLClient(client: rawClient)

_ = try await client.batch(
  D1Query<D1Void>(
    statement: """
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        count INTEGER NOT NULL
      )
      """,
    params: []
  )
)

@D1Table(schema: "users")
struct User: Sendable, Hashable {
  @D1Column
  var id: UUID

  @D1Column
  var name: String

  @D1Column
  var count: Int
}

let userID = UUID()
let user = User(id: userID, name: "Alice", count: 1)

let (_, fetched) = try await client.batch(
  user.create(),
  User.select().filter(\.id == userID).first()
)
```

## ライセンス

MIT License
