import MacroTesting
import Testing

@testable import D1LiteMacro

@Suite(.macros([D1TableMacro.self, D1ColumnMacro.self]))
struct D1TableMacroTests {
  @Test func testTableExpansion() {
    assertMacro {
      #"""
      struct Profile: Codable, Hashable {
        var bio: String
      }

      @D1Table(schema: "samples")
      struct Sample: Hashable {
        @D1Column
        var id: UUID
        @D1Column(name: "is_active")
        var isActive: Bool
        @D1Column
        var blob: Data
        @D1Column
        var createdAt: Date
        @D1Column(formatStyle: D1Lite.D1DateFormatStyle(format: .epoch))
        var updatedAt: Date
        @D1Column(formatStyle: D1Lite.D1DateFormatStyle(format: .yyyyMMdd))
        var birthday: Date
        @D1Column(name: "expires_at", formatStyle: D1Lite.D1DateFormatStyle(format: .iso8601))
        var expiresAt: Date
        @D1Column
        var score: Double
        @D1Column
        var count: Int
        @D1Column
        var name: String
        @D1Column(name: "nick_name")
        var nickname: String?
        @D1Column
        var profile: Profile
      }
      """#
    } expansion: {
      #"""
      struct Profile: Codable, Hashable {
        var bio: String
      }
      struct Sample: Hashable {
        var id: UUID
        var isActive: Bool
        var blob: Data
        var createdAt: Date
        var updatedAt: Date
        var birthday: Date
        var expiresAt: Date
        var score: Double
        var count: Int
        var name: String
        var nickname: String?
        var profile: Profile

        init(id: UUID, isActive: Bool, blob: Data, createdAt: Date, updatedAt: Date, birthday: Date, expiresAt: Date, score: Double, count: Int, name: String, nickname: String?, profile: Profile) {
          self.id = id
          self.isActive = isActive
          self.blob = blob
          self.createdAt = createdAt
          self.updatedAt = updatedAt
          self.birthday = birthday
          self.expiresAt = expiresAt
          self.score = score
          self.count = count
          self.name = name
          self.nickname = nickname
          self.profile = profile
        }

        static let schema = "samples"

        static let columns = ["id", "is_active", "blob", "createdAt", "updatedAt", "birthday", "expires_at", "score", "count", "name", "nick_name", "profile"]

        static let id: D1Lite.D1Column<UUID, D1Lite.D1UUIDFormatStyle> = D1Lite.D1Column(
          name: "id",
          formatStyle: D1Lite.D1UUIDFormatStyle()
        )

        static let isActive: D1Lite.D1Column<Bool, D1Lite.D1BoolFormatStyle> = D1Lite.D1Column(
          name: "is_active",
          formatStyle: D1Lite.D1BoolFormatStyle()
        )

        static let blob: D1Lite.D1Column<Data, D1Lite.D1DataFormatStyle> = D1Lite.D1Column(
          name: "blob",
          formatStyle: D1Lite.D1DataFormatStyle()
        )

        static let createdAt: D1Lite.D1Column<Date, D1Lite.D1DateFormatStyle> = D1Lite.D1Column(
          name: "createdAt",
          formatStyle: D1Lite.D1DateFormatStyle(format: D1Lite.D1FormatStyle.DateFormat.iso8601)
        )

        static let updatedAt: D1Lite.D1Column<Date, D1Lite.D1DateFormatStyle> = D1Lite.D1Column(
          name: "updatedAt",
          formatStyle: D1Lite.D1DateFormatStyle(format: .epoch)
        )

        static let birthday: D1Lite.D1Column<Date, D1Lite.D1DateFormatStyle> = D1Lite.D1Column(
          name: "birthday",
          formatStyle: D1Lite.D1DateFormatStyle(format: .yyyyMMdd)
        )

        static let expiresAt: D1Lite.D1Column<Date, D1Lite.D1DateFormatStyle> = D1Lite.D1Column(
          name: "expires_at",
          formatStyle: D1Lite.D1DateFormatStyle(format: .iso8601)
        )

        static let score: D1Lite.D1Column<Double, D1Lite.D1DoubleFormatStyle> = D1Lite.D1Column(
          name: "score",
          formatStyle: D1Lite.D1DoubleFormatStyle()
        )

        static let count: D1Lite.D1Column<Int, D1Lite.D1IntFormatStyle> = D1Lite.D1Column(
          name: "count",
          formatStyle: D1Lite.D1IntFormatStyle()
        )

        static let name: D1Lite.D1Column<String, D1Lite.D1StringFormatStyle> = D1Lite.D1Column(
          name: "name",
          formatStyle: D1Lite.D1StringFormatStyle()
        )

        static let nickname: D1Lite.D1Column<String?, D1Lite.D1OptionalFormatStyle<D1Lite.D1StringFormatStyle>> = D1Lite.D1Column(
          name: "nick_name",
          formatStyle: D1Lite.D1OptionalFormatStyle(D1Lite.D1StringFormatStyle())
        )

        static let profile: D1Lite.D1Column<Profile, D1Lite.D1CodableFormatStyle<Profile>> = D1Lite.D1Column(
          name: "profile",
          formatStyle: D1Lite.D1CodableFormatStyle<Profile>()
        )

        static let allColumnNames: [Swift.String] = [Self.id.name, Self.isActive.name, Self.blob.name, Self.createdAt.name, Self.updatedAt.name, Self.birthday.name, Self.expiresAt.name, Self.score.name, Self.count.name, Self.name.name, Self.nickname.name, Self.profile.name]

        var allD1Values: [D1Lite.D1Value] {
          [Self.id.format(value: id), Self.isActive.format(value: isActive), Self.blob.format(value: blob), Self.createdAt.format(value: createdAt), Self.updatedAt.format(value: updatedAt), Self.birthday.format(value: birthday), Self.expiresAt.format(value: expiresAt), Self.score.format(value: score), Self.count.format(value: count), Self.name.format(value: name), Self.nickname.format(value: nickname), Self.profile.format(value: profile)]
        }

        static func d1Format<Value: Swift.Sendable>(_ keyPath: Swift.KeyPath<Self, Value>, value: Value) -> D1Lite.D1Value {
          switch keyPath {
          case \Self.id:
            Self.id.format(any: value)
          case \Self.isActive:
            Self.isActive.format(any: value)
          case \Self.blob:
            Self.blob.format(any: value)
          case \Self.createdAt:
            Self.createdAt.format(any: value)
          case \Self.updatedAt:
            Self.updatedAt.format(any: value)
          case \Self.birthday:
            Self.birthday.format(any: value)
          case \Self.expiresAt:
            Self.expiresAt.format(any: value)
          case \Self.score:
            Self.score.format(any: value)
          case \Self.count:
            Self.count.format(any: value)
          case \Self.name:
            Self.name.format(any: value)
          case \Self.nickname:
            Self.nickname.format(any: value)
          case \Self.profile:
            Self.profile.format(any: value)
          default:
            fatalError("未対応のキーです。")
          }
        }

        static func d1ColumnName<Value: Swift.Sendable>(_ keyPath: Swift.KeyPath<Self, Value>) -> Swift.String {
          switch keyPath {
          case \Self.id:
            Self.id.name
          case \Self.isActive:
            Self.isActive.name
          case \Self.blob:
            Self.blob.name
          case \Self.createdAt:
            Self.createdAt.name
          case \Self.updatedAt:
            Self.updatedAt.name
          case \Self.birthday:
            Self.birthday.name
          case \Self.expiresAt:
            Self.expiresAt.name
          case \Self.score:
            Self.score.name
          case \Self.count:
            Self.count.name
          case \Self.name:
            Self.name.name
          case \Self.nickname:
            Self.nickname.name
          case \Self.profile:
            Self.profile.name
          default:
            fatalError("未対応のキーです。")
          }
        }

        static func decode(d1 record: [Swift.String: D1Lite.D1Value]) throws -> Self {
          guard let idValue = record["id"] else {
            throw D1Lite.D1TableDecodingError.missingValue(property: "id", column: "id")
          }
          guard let isActiveValue = record["is_active"] else {
            throw D1Lite.D1TableDecodingError.missingValue(property: "isActive", column: "is_active")
          }
          guard let blobValue = record["blob"] else {
            throw D1Lite.D1TableDecodingError.missingValue(property: "blob", column: "blob")
          }
          guard let createdAtValue = record["createdAt"] else {
            throw D1Lite.D1TableDecodingError.missingValue(property: "createdAt", column: "createdAt")
          }
          guard let updatedAtValue = record["updatedAt"] else {
            throw D1Lite.D1TableDecodingError.missingValue(property: "updatedAt", column: "updatedAt")
          }
          guard let birthdayValue = record["birthday"] else {
            throw D1Lite.D1TableDecodingError.missingValue(property: "birthday", column: "birthday")
          }
          guard let expiresAtValue = record["expires_at"] else {
            throw D1Lite.D1TableDecodingError.missingValue(property: "expiresAt", column: "expires_at")
          }
          guard let scoreValue = record["score"] else {
            throw D1Lite.D1TableDecodingError.missingValue(property: "score", column: "score")
          }
          guard let countValue = record["count"] else {
            throw D1Lite.D1TableDecodingError.missingValue(property: "count", column: "count")
          }
          guard let nameValue = record["name"] else {
            throw D1Lite.D1TableDecodingError.missingValue(property: "name", column: "name")
          }
          guard let nicknameValue = record["nick_name"] else {
            throw D1Lite.D1TableDecodingError.missingValue(property: "nickname", column: "nick_name")
          }
          guard let profileValue = record["profile"] else {
            throw D1Lite.D1TableDecodingError.missingValue(property: "profile", column: "profile")
          }
          return self.init(
            id: try Self.id.parse(d1: idValue),
            isActive: try Self.isActive.parse(d1: isActiveValue),
            blob: try Self.blob.parse(d1: blobValue),
            createdAt: try Self.createdAt.parse(d1: createdAtValue),
            updatedAt: try Self.updatedAt.parse(d1: updatedAtValue),
            birthday: try Self.birthday.parse(d1: birthdayValue),
            expiresAt: try Self.expiresAt.parse(d1: expiresAtValue),
            score: try Self.score.parse(d1: scoreValue),
            count: try Self.count.parse(d1: countValue),
            name: try Self.name.parse(d1: nameValue),
            nickname: try Self.nickname.parse(d1: nicknameValue),
            profile: try Self.profile.parse(d1: profileValue)
          )
        }
      }

      extension Sample: D1Lite.D1Table {
      }
      """#
    }
  }
}
