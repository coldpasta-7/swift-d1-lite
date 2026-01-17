# `D1Lite`

Cloudflare D1 を ReadModel として扱うための軽量 ORM です。D1 の raw
クエリ実行、マクロによるテーブル定義、フォーマットスタイルによる値変換を中心に、最小構成で
Swift から扱えることを目指しています。

## 対象

- Cloudflare D1 を Swift から型安全に扱いたい方
- ReadModel 用の軽量な ORM が欲しい方
- マクロベースでテーブル定義をまとめたい方

## 概要

- `@D1Table` と `@D1Column` でテーブル定義用の補助メンバーを生成します。
- `D1SQLClient` が複数クエリのバッチ実行をまとめます。
- `D1FormatStyle` 系で D1 の値と Swift の型を相互変換します。

## クイックスタート

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
  User.select().filter(\.id == userID).first(),
)
```

## マクロとモデル定義

`@D1Table` は `D1Table` に準拠し、`schema` や `allColumnNames`、`allD1Values`
などの補助メンバーを生成します。`@D1Column`
はカラム名の上書きやフォーマット指定に使います。

```swift
@D1Table(schema: "users")
struct User: Sendable {
  @D1Column(name: "user_id")
  var id: UUID
}
```

## 値変換

`D1FormatStyle` は D1 の値表現と Swift の型の間を橋渡しします。例えば日付を
epoch 秒や ISO 8601 文字列として保存したい場合に利用します。

```swift
@D1Column(name: "created_at", formatStyle: D1DateFormatStyle(format: .epoch))
var createdAt: Date
```

## クエリの組み立て

`D1Table` の拡張を使って `select` / `update` / `delete` / `create`
のクエリを組み立てます。生成された `D1Query` は `D1SQLClient` の `batch`
で実行します。

```swift
let query = User.select()
  .filter(\.name == "Alice")
  .all()

let update = User.update()
  .set(\.name, "Bob")
  .filter(\.id == userID)
  .build()

let delete = User.delete()
  .filter(\.id == userID)
  .build()
```
