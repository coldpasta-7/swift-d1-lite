# `D1LiteSQLite`

ローカルの SQLite またはメモリ上で D1 互換の raw
クエリを実行する実装です。`D1RawDatabaseQueryClient`
に準拠しているため、`D1SQLClient`
をそのまま使えます。テストや開発時のスタブとして利用できます。

## 対象

- ローカルで D1 相当の挙動を再現したい場合
- テストや開発環境で D1 の代替として使いたい場合

## 使い方

### インメモリ

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

### ファイル

```swift
import D1Lite
import D1LiteSQLite
import Foundation
import SystemPackage

let path = FilePath("/tmp/d1lite.sqlite")
let rawClient = SQLiteD1RawDatabaseQueryClient(config: .file(path))
let client = D1SQLClient(client: rawClient)
```

## 依存関係

内部では `SQLiteNIO` を利用しています。Swift Package Manager
が依存関係を解決するため、通常は追加の設定は不要です。

## 設定キー

`ConfigReader` で読み取るキーは以下です。

- `d1.inmemory`（`true` ならインメモリを利用）
- `d1.sqlite.file.path`（`d1.inmemory` が `false` の場合に必須）
