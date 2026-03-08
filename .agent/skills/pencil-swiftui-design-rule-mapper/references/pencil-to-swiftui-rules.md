# Pencil to SwiftUI Rule Mapping

Use this document as the normative mapping contract when translating Pencil design rules into SwiftUI implementation details.

## Naming

- Convert reusable Pencil component names to SwiftUI struct names with PascalCase.
- Normalize separators (`/`, space, `_`, `-`) into word boundaries.
- Append `component_struct_suffix` for reusable component structs.
- Register exceptions explicitly in `component_name_map`.

## Spacing

- Map all Pencil spacing tokens to symbols like `Spacing.sm`.
- Use token symbols in `.padding(...)` and stack `spacing:`.
- Avoid raw numeric spacing values unless explicitly whitelisted by `allowed_numeric_spacing_values`.

## Typography

- Map all Pencil typography tokens to symbols like `Typography.bodyM`.
- Use typography symbols in `.font(...)`.
- Avoid `.font(.system(...))` and `.font(.custom(..., size: ...))` because they bypass token mapping.

## Accessibility Labels

- Provide `.accessibilityLabel(...)` for interactive controls and meaningful images.
- Use `.accessibilityHidden(true)` for decorative images.
- Provide `.accessibilityIdentifier(...)` for interactive controls when UI testing or automation is expected.

## Suggested Mapping Direction

1. Gather Pencil variables and reusable components.
2. Update `mapping-manifest.json` with exact one-to-one mappings.
3. Refactor SwiftUI code to token symbols and mapped component names.
4. Run `scripts/swiftui_rule_audit.py`.
5. Resolve violations until clean.
