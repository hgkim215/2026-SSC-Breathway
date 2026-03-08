#!/usr/bin/env python3
"""Audit SwiftUI files against Pencil-to-SwiftUI mapping rules."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path


DEFAULT_MANIFEST = {
    "component_struct_suffix": "View",
    "component_name_map": {},
    "spacing_token_prefixes": ["Spacing."],
    "typography_token_prefixes": ["Typography."],
    "allowed_numeric_spacing_values": [0],
    "a11y_required_types": ["Button", "Toggle", "TextField", "SecureField", "Image"],
    "a11y_scan_window": 12,
    "a11y_require_identifier_for_interactive": True,
    "interactive_types": ["Button", "Toggle", "TextField", "SecureField"],
}


def load_manifest(path: Path) -> dict:
    data = dict(DEFAULT_MANIFEST)
    if not path.exists():
        return data
    loaded = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(loaded, dict):
        raise ValueError("Manifest must be a JSON object.")
    data.update(loaded)
    return data


def collect_swift_files(paths: list[str]) -> list[Path]:
    files: list[Path] = []
    for raw in paths:
        path = Path(raw)
        if not path.exists():
            continue
        if path.is_file() and path.suffix == ".swift":
            files.append(path)
            continue
        if path.is_dir():
            for candidate in path.rglob("*.swift"):
                parts = set(candidate.parts)
                if ".build" in parts or "Pods" in parts:
                    continue
                files.append(candidate)
    files = sorted(set(files))
    return files


def is_pascal_case(name: str) -> bool:
    return bool(re.fullmatch(r"[A-Z][A-Za-z0-9]*", name))


def contains_any_prefix(text: str, prefixes: list[str]) -> bool:
    return any(prefix in text for prefix in prefixes)


def as_float_set(values: list[object]) -> set[float]:
    result: set[float] = set()
    for value in values:
        try:
            result.add(float(value))
        except (TypeError, ValueError):
            continue
    return result


def strip_inline_comment(line: str) -> str:
    return line.split("//", 1)[0]


def compile_a11y_patterns(required_types: list[str]) -> dict[str, re.Pattern[str]]:
    patterns: dict[str, re.Pattern[str]] = {}
    for view_type in required_types:
        escaped = re.escape(view_type)
        if view_type == "Button":
            patterns[view_type] = re.compile(rf"\b{escaped}\s*(\(|\{{)")
        else:
            patterns[view_type] = re.compile(rf"\b{escaped}\s*\(")
    return patterns


def add_violation(violations: list[dict], path: Path, line_no: int, rule: str, message: str, snippet: str) -> None:
    violations.append(
        {
            "path": str(path),
            "line": line_no,
            "rule": rule,
            "message": message,
            "snippet": snippet.strip(),
        }
    )


def audit_file(path: Path, manifest: dict, violations: list[dict], declared_views: set[str]) -> None:
    lines = path.read_text(encoding="utf-8").splitlines()

    suffix = str(manifest.get("component_struct_suffix", "View"))
    spacing_prefixes = list(manifest.get("spacing_token_prefixes", ["Spacing."]))
    typography_prefixes = list(manifest.get("typography_token_prefixes", ["Typography."]))
    allowed_spacing = as_float_set(list(manifest.get("allowed_numeric_spacing_values", [0])))
    required_types = list(manifest.get("a11y_required_types", DEFAULT_MANIFEST["a11y_required_types"]))
    interactive_types = set(manifest.get("interactive_types", DEFAULT_MANIFEST["interactive_types"]))
    require_identifier = bool(manifest.get("a11y_require_identifier_for_interactive", True))
    scan_window = int(manifest.get("a11y_scan_window", 12))
    a11y_patterns = compile_a11y_patterns(required_types)

    for idx, raw in enumerate(lines):
        line_no = idx + 1
        line = strip_inline_comment(raw)

        # Naming enforcement for SwiftUI view structs.
        struct_match = re.search(r"^\s*struct\s+([A-Za-z_][A-Za-z0-9_]*)\s*:\s*View\b", line)
        if struct_match:
            struct_name = struct_match.group(1)
            declared_views.add(struct_name)
            if not is_pascal_case(struct_name):
                add_violation(
                    violations,
                    path,
                    line_no,
                    "naming",
                    f"View struct '{struct_name}' must be PascalCase.",
                    raw,
                )
            if suffix and not struct_name.endswith(suffix):
                add_violation(
                    violations,
                    path,
                    line_no,
                    "naming",
                    f"View struct '{struct_name}' must end with '{suffix}'.",
                    raw,
                )

        # Spacing enforcement.
        for match in re.finditer(r"\.padding\(\s*(?:\.[A-Za-z_][A-Za-z0-9_]*\s*,\s*)?(-?\d+(?:\.\d+)?)\s*\)", line):
            value = float(match.group(1))
            if value not in allowed_spacing:
                add_violation(
                    violations,
                    path,
                    line_no,
                    "spacing",
                    f"Raw spacing literal {value:g} in padding is not allowed.",
                    raw,
                )

        for match in re.finditer(r"\bspacing\s*:\s*(-?\d+(?:\.\d+)?)\b", line):
            value = float(match.group(1))
            if value not in allowed_spacing:
                add_violation(
                    violations,
                    path,
                    line_no,
                    "spacing",
                    f"Raw spacing literal {value:g} in stack spacing is not allowed.",
                    raw,
                )

        if ".padding(" in line and ".padding()" not in line:
            if not contains_any_prefix(line, spacing_prefixes):
                if not re.search(
                    r"\.padding\(\s*(?:\.[A-Za-z_][A-Za-z0-9_]*\s*,\s*)?(-?\d+(?:\.\d+)?)\s*\)",
                    line,
                ):
                    add_violation(
                        violations,
                        path,
                        line_no,
                        "spacing",
                        "Padding must use spacing token prefix from manifest.",
                        raw,
                    )

        if "spacing:" in line and not contains_any_prefix(line, spacing_prefixes):
            if not re.search(r"\bspacing\s*:\s*(-?\d+(?:\.\d+)?)\b", line):
                add_violation(
                    violations,
                    path,
                    line_no,
                    "spacing",
                    "Stack spacing must use spacing token prefix from manifest.",
                    raw,
                )

        # Typography enforcement.
        if re.search(r"\.font\(\s*\.system\b", line):
            add_violation(
                violations,
                path,
                line_no,
                "typography",
                "Do not use .font(.system(...)); map to typography tokens.",
                raw,
            )

        if re.search(r"\.font\(\s*\.custom\([^)]*size\s*:\s*-?\d+(?:\.\d+)?", line):
            add_violation(
                violations,
                path,
                line_no,
                "typography",
                "Do not use .font(.custom(..., size: ...)); map to typography tokens.",
                raw,
            )

        if ".font(" in line and not contains_any_prefix(line, typography_prefixes):
            if not re.search(r"\.font\(\s*Typography\.", line):
                if not re.search(r"\.font\(\s*\.?(caption|body|headline|title|largeTitle|subheadline|footnote)\b", line):
                    add_violation(
                        violations,
                        path,
                        line_no,
                        "typography",
                        "Font must use typography token prefix from manifest.",
                        raw,
                    )

        # Accessibility enforcement.
        for view_type, pattern in a11y_patterns.items():
            if not pattern.search(line):
                continue
            window_end = min(len(lines), idx + 1 + scan_window)
            window_text = "\n".join(lines[idx:window_end])
            has_label = ".accessibilityLabel(" in window_text
            has_identifier = ".accessibilityIdentifier(" in window_text
            image_hidden = ".accessibilityHidden(true)" in window_text.replace(" ", "")

            if view_type == "Image":
                if not has_label and not image_hidden:
                    add_violation(
                        violations,
                        path,
                        line_no,
                        "accessibility",
                        "Image requires accessibilityLabel or accessibilityHidden(true).",
                        raw,
                    )
            else:
                if not has_label:
                    add_violation(
                        violations,
                        path,
                        line_no,
                        "accessibility",
                        f"{view_type} requires accessibilityLabel.",
                        raw,
                    )
                if require_identifier and view_type in interactive_types and not has_identifier:
                    add_violation(
                        violations,
                        path,
                        line_no,
                        "accessibility",
                        f"{view_type} requires accessibilityIdentifier.",
                        raw,
                    )


def audit_manifest_mappings(manifest: dict, declared_views: set[str], violations: list[dict], manifest_path: Path) -> None:
    component_name_map = manifest.get("component_name_map", {})
    if not isinstance(component_name_map, dict):
        return
    suffix = str(manifest.get("component_struct_suffix", "View"))

    for pencil_name, swift_name in component_name_map.items():
        if not isinstance(swift_name, str):
            continue
        if not is_pascal_case(swift_name):
            add_violation(
                violations,
                manifest_path,
                1,
                "naming",
                f"Mapped SwiftUI name '{swift_name}' for '{pencil_name}' must be PascalCase.",
                swift_name,
            )
        if suffix and not swift_name.endswith(suffix):
            add_violation(
                violations,
                manifest_path,
                1,
                "naming",
                f"Mapped SwiftUI name '{swift_name}' for '{pencil_name}' must end with '{suffix}'.",
                swift_name,
            )
        if swift_name not in declared_views:
            add_violation(
                violations,
                manifest_path,
                1,
                "naming",
                f"Mapped SwiftUI type '{swift_name}' for '{pencil_name}' is not declared in scanned files.",
                swift_name,
            )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Audit SwiftUI files against Pencil mapping rules.")
    parser.add_argument("--manifest", required=True, help="Path to mapping manifest JSON.")
    parser.add_argument(
        "--paths",
        nargs="+",
        required=True,
        help="Swift files or directories to audit.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    manifest_path = Path(args.manifest)
    try:
        manifest = load_manifest(manifest_path)
    except (json.JSONDecodeError, ValueError) as exc:
        print(f"[ERROR] Invalid manifest: {exc}")
        return 2

    swift_files = collect_swift_files(args.paths)
    if not swift_files:
        print("[ERROR] No Swift files found in provided paths.")
        return 2

    violations: list[dict] = []
    declared_views: set[str] = set()

    for swift_file in swift_files:
        audit_file(swift_file, manifest, violations, declared_views)

    audit_manifest_mappings(manifest, declared_views, violations, manifest_path)

    if not violations:
        print(f"[PASS] No violations across {len(swift_files)} Swift file(s).")
        return 0

    category_counts: dict[str, int] = {}
    for violation in violations:
        category_counts[violation["rule"]] = category_counts.get(violation["rule"], 0) + 1

    print(f"[FAIL] {len(violations)} violation(s) found.")
    for category in sorted(category_counts):
        print(f"- {category}: {category_counts[category]}")
    print("")

    for violation in violations:
        print(
            f"[{violation['rule']}] {violation['path']}:{violation['line']} - {violation['message']}"
        )
        if violation["snippet"]:
            print(f"  {violation['snippet']}")

    return 1


if __name__ == "__main__":
    sys.exit(main())
