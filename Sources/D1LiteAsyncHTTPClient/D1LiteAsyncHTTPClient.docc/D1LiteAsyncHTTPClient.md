# `D1LiteAsyncHTTPClient`

AsyncHTTPClient を使って Cloudflare D1 の raw
クエリを実行する実装を提供します。Cloudflare の HTTP API を経由してリモートの D1
を操作したい場合に利用します。`D1RawDatabaseQueryClient`
に準拠しているため、`D1SQLClient` から利用できます。

## 対象

- Cloudflare D1 のリモート API を使うアプリケーション
- D1 の raw クエリを Swift から実行したい場合

## 認証

Cloudflare D1 の API トークンが必要です。トークンは Cloudflare
ダッシュボードで作成し、環境変数など安全な経路で注入します。

## 使い方

```swift
import AsyncHTTPClient
import Configuration
import D1Lite
import D1LiteAsyncHTTPClient
import Foundation

@D1Table(schema: "users")
struct User: Sendable, Hashable {
  @D1Column
  var id: UUID

  @D1Column
  var name: String
}

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

## エラーハンドリング

ネットワークエラーや認証エラーは `AsyncHTTPClient` 側の例外として扱われます。D1
の API が返したエラーは `D1RawDatabaseQueryClientError` として報告されます。

## 設定キー

`ConfigReader` で読み取るキーは以下です。

- `d1.account.id`
- `d1.database.id`
- `d1.api.token`
- `d1.base.url`（任意）
- `d1.http.request.timeout.sec`（任意）
- `d1.http.request.response.max.bytes`（任意）
