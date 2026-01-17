public import Foundation

/// UUID を D1 の値へ変換するフォーマットスタイルです.
public struct D1UUIDFormatStyle: Sendable, ParseableFormatStyle {
  /// フォーマットスタイルを作成.
  public init() {}

  /// UUID の解析戦略.
  public var parseStrategy: Strategy { .init() }

  /// UUID を D1 の値へ変換します.
  public func format(_ value: UUID) -> D1Value {
    .string(value.uuidString)
  }

  /// UUID の解析戦略.
  public struct Strategy: ParseStrategy {
    /// D1 の値から UUID を取り出します.
    public func parse(_ value: D1Value) throws -> UUID {
      guard case .string(let string) = value else {
        throw D1FormatStyle.ParseError.requiredString(value)
      }
      guard let uuid = UUID(uuidString: string) else {
        throw D1FormatStyle.ParseError.invalidFormat(value, typename: "UUID", message: "UUID 形式である必要があります.")
      }
      return uuid
    }
  }
}
