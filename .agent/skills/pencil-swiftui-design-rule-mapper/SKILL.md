---
name: pencil-swiftui-design-rule-mapper
description: Map Pencil MCP design tokens and reusable components to enforced SwiftUI coding rules. Use when generating or refactoring SwiftUI from .pen-based designs and you must enforce naming conventions, spacing tokens, typography tokens, and accessibility labels/identifiers with lintable checks.
---

# Pencil SwiftUI Design Rule Mapper

## Workflow

1. Extract design sources of truth from Pencil.
- Call `mcp__pencil__get_variables` for design tokens.
- Call `mcp__pencil__batch_get` with `patterns: [{"reusable": true}]` to collect reusable components.
- Stop and ask for clarification if tokens or reusable components are missing.

2. Create the mapping manifest before editing SwiftUI.
- Copy `references/mapping-manifest.template.json` to a project-local manifest.
- Fill `component_name_map` from Pencil component names to SwiftUI type names.
- Confirm token prefixes in code (`spacing_token_prefixes`, `typography_token_prefixes`).
- Set `component_struct_suffix` (default `View`) for reusable component structs.

3. Apply enforced SwiftUI rules.
- Naming:
- Use PascalCase for reusable component structs.
- End reusable component structs with `component_struct_suffix`.
- Use `component_name_map` aliases when Pencil names contain spaces or `/`.
- Spacing:
- Do not use raw numeric literals in `.padding(...)` or `spacing:`.
- Use spacing tokens only (`Spacing.*` or configured prefixes).
- Allow numeric spacing only when explicitly listed in `allowed_numeric_spacing_values`.
- Typography:
- Do not use `.font(.system(...))` or `.font(.custom(..., size: ...))`.
- Use typography tokens only (`Typography.*` or configured prefixes).
- Accessibility:
- Require explicit `.accessibilityLabel(...)` for `Button`, `Toggle`, `TextField`, `SecureField`, and `Image`.
- For decorative images, allow `.accessibilityHidden(true)` instead of label.
- Require `.accessibilityIdentifier(...)` for interactive controls when `a11y_require_identifier_for_interactive` is true.

4. Enforce with deterministic audit.
- Run `scripts/swiftui_rule_audit.py --manifest <manifest.json> --paths <swift file/dir ...>`.
- Treat exit code `1` as a hard block unless the user accepts an explicit waiver.

5. Report with traceability.
- Group fixes by `naming`, `spacing`, `typography`, and `accessibility`.
- Include file/line references and rationale for any accepted waivers.

## Execution Notes

- Iterate in short loops: audit -> patch -> audit.
- Keep the manifest as the contract between design and code.
- Prefer local/offline checks only.

## Resources

### `scripts/swiftui_rule_audit.py`
Run lint-style enforcement for naming, spacing, typography, and accessibility rules.

### `references/mapping-manifest.template.json`
Start each project mapping contract from this template.
