import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct D1LiteMacroPlugin: CompilerPlugin {
  let providingMacros: [any Macro.Type] = [
    D1TableMacro.self,
    D1ColumnMacro.self,
  ]
}
