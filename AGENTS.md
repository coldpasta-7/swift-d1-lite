# Swift D1 ORM

## 概要

CQRS・ESにおいてCloudflare
D1をReadModelのDBとして扱い、Swiftから更新をかけるための必要最低限の軽量ORMです。

## タスク実行方針

- Small
  テストでのテスタビリティおよびテスト網羅性を重視します。タスクで実装を行う際には必ずテスト網羅されていることと`swift test`がPASSすることを確認してください
- swiftlang/swift-formatでのformatおよびlintでの品質確認を行います。タスク完了時には`swift format lint -r .`がPASSすることを確認してください。formatには`swift format -i -r .`を利用してください
- DocCには日本語で記述をしてください
