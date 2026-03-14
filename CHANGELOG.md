# Changelog

All notable changes to this project will be documented in this file.

## [0.2.0] - 2026-03-15

### Added

- `0.2` generated-query framework for host adapters and runtime query synthesis.
- Generated host support for `python`, `javascript`, `typescript`, `lua`, and `ruby`.
- `:TSInjectReload` and `:TSInjectHealth`.
- Experimental host-level rule configuration for configurable generated hosts:
  - `rules.<host>.builtin`
  - `rules.<host>.items`
- Optional per-host query mode override:
  - `query_mode.<host> = "generated" | "static"`

### Changed

- `lua` and `ruby` moved from static runtime queries to generated runtime queries.
- Generated-capable hosts default to generated mode; static mode is available as a legacy fallback.
- Health reporting now includes:
  - generated/static split
  - generated query file status
  - builtin/user rule counts
  - legacy static host status
- Static query snapshots for generated hosts moved to `archive/scm-generated/` (reference only).

### Testing

- Expanded smoke coverage for:
  - reload behavior
  - health output
  - generated-host migration paths
  - `builtin = false` behavior
  - legacy static mode behavior

## [0.1.0] - 2026-03-13

### Added

- Initial public release of `ts-inject.nvim`.
- Static SQL injection support across host languages:
  - `bash`, `c`, `cpp`, `c_sharp`, `go`, `java`, `javascript`, `kotlin`, `lua`,
    `php`, `python`, `ruby`, `scala`, `rust`, `typescript`, `zig`
- `setup({ enable = { ... } })` explicit host opt-in model.
- `:TSInjectDebug` command for runtime/parser/query inspection.
- Runtime-installed host query files for enabled languages.
- Project docs/help and baseline test fixtures/smoke validation.

### Notes

- `0.1.x` focused on stable static host-specific SQL recipes and debugging.
- Generic rule-engine style behavior was intentionally deferred to `0.2+`.
