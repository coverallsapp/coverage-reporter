# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Project Overview

Universal Coverage Reporter written in Crystal. Auto-detects coverage artifact
files and CI environments to post coverage data to Coveralls.io. Supports
multiple coverage formats (Lcov, SimpleCov, Cobertura, Jacoco, Gcov, Golang,
Python, Clover, Coveralls) and CI services (GitHub Actions, CircleCI, Travis,
Jenkins, GitLab, etc.).

## Development Commands

```bash
# Install dependencies
shards install

# Build the project (creates bin/coveralls)
make build

# Run test suite
make test

# Run linter
make lint

# Run a single spec file
crystal spec spec/path/to/spec_file.cr

# Run specs with specific focus
crystal spec --tag focus

# Test the built binary
bin/coveralls --help
bin/coveralls report --debug --dry-run
```

## Testing

- Testing framework: **Spectator** (BDD-style spec framework)
- Spec files: `spec/coverage_reporter/*_spec.cr`
- Test fixtures: `spec/fixtures/`
- Python virtual environment (`.venv/`) is auto-created for Python-related tests
- Tests use `ENV` mocking extensively for CI detection testing

## Architecture

### Core Flow

1. **CLI** (`src/cli.cr`, `src/coverage_reporter/cli/cmd.cr`) - Parses arguments
   and invokes Reporter
2. **Reporter** (`src/coverage_reporter/reporter.cr`) - Main orchestration:
   - Calls Parser to find and parse coverage files
   - Sends parsed data to Coveralls API via Api::Jobs or Api::Webhook
3. **Parser** (`src/coverage_reporter/parser.cr`) - Coverage file discovery and
   parsing:
   - Auto-detects coverage files using glob patterns if not specified
   - Delegates to format-specific parsers
4. **Parsers** (`src/coverage_reporter/parsers/*`) - Format-specific parsing logic
5. **CI Modules** (`src/coverage_reporter/ci/*`) - CI-specific environment detection
6. **Config** (`src/coverage_reporter/config.cr`) - Configuration with priority:
   CLI args > ENV vars > YAML config
7. **API** (`src/coverage_reporter/api/*`) - HTTP communication with Coveralls

### Configuration Hierarchy

Configuration is resolved in this order (highest priority first):

1. CLI arguments (`--repo-token`, `--service-name`, etc.)
2. Environment variables (`COVERALLS_*` or `CI_*`)
3. YAML config file (`.coveralls.yml`)
4. CI-specific ENV detection (auto-detected from `CI_OPTIONS` in `config.cr`)

### Parser System

All parsers inherit from `BaseParser` and implement:

- `globs : Array(String)` - Glob patterns for auto-detection
- `matches?(filename : String) : Bool` - Check if file can be parsed
- `parse(filename : String) : Array(FileReport)` - Parse file and return
  coverage data

The `Parser` class iterates through `PARSERS` tuple to find matching parser.

### CI Detection System

Each CI module in `src/coverage_reporter/ci/` implements:

- `.options` method returning `CI::Options` or `nil`
- Returns `nil` if environment doesn't match the CI
- Extracts service_name, job_id, branch, PR number, commit SHA, etc. from ENV

The `Config` class tries each CI module in `CI_OPTIONS` tuple until one matches.

## Adding New Coverage Formats

1. Create parser class in `src/coverage_reporter/parsers/my_parser.cr`
   inheriting `BaseParser`
2. Implement `globs`, `matches?`, and `parse` methods
3. Add to `PARSERS` tuple in `src/coverage_reporter/parser.cr`
4. Add specs in `spec/coverage_reporter/parsers/my_parser_spec.cr`

See `doc/development.md` for detailed checklist.

## Adding New CI Support

1. Create module in `src/coverage_reporter/ci/my_ci.cr` implementing `.options`
   method
2. Return `nil` if ENV doesn't match CI, otherwise return `CI::Options` with
   extracted values
3. Add to `CI_OPTIONS` tuple in `src/coverage_reporter/config.cr`
4. Add specs in `spec/coverage_reporter/config_spec.cr`

See `doc/development.md` for detailed checklist.

## Build System

- Cross-compilation uses Docker with `xbuild` (zig-based cross-compiler)
- Targets: Linux x86_64, Linux aarch64, macOS (via Homebrew), Windows
- `make compile-and-strip-all` - Build binaries for all Linux architectures
- `make package` - Create distribution tarballs
- GitHub Actions automates releases when tags are pushed

## Release Process

Automated via `make new_version`:

1. Prompts for version and description
2. Updates `shard.yml` and `src/coverage_reporter.cr`
3. Creates commit and annotated tag
4. Pushes with `--follow-tags` to trigger GitHub release workflow

Manual process documented in README.md if needed.

## Important Files

- `src/cli.cr` - Entry point
- `src/coverage_reporter.cr` - Module definition and VERSION constant
- `src/coverage_reporter/cli/cmd.cr` - CLI argument parsing and error handling
- `src/coverage_reporter/reporter.cr` - Main business logic
- `src/coverage_reporter/parser.cr` - Coverage file discovery/parsing coordination
- `src/coverage_reporter/config.cr` - Configuration resolution
- `src/coverage_reporter/source_files.cr` - Coverage data aggregation
- `src/coverage_reporter/git.cr` - Git metadata extraction
- `shard.yml` - Crystal dependencies and version
- `Makefile` - Build automation
