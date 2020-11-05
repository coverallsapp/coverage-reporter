```
⠀⠀⠀⠀⠀⠀⣿
⠀⠀⠀⠀⠀⣼⣿⣧⠀⠀⠀⠀⠀⠀⠀ ⣠⣶⣾⣿⡇⢀⣴⣾⣿⣷⣆ ⣿⣿⠀⣰⣿⡟⢸⣿⣿⣿⡇ ⣿⣿⣿⣷⣦⠀⠀⢠⣿⣿⣿⠀⠀⣿⣿⠁⠀⣼⣿⡇⠀⢀⣴⣾⣿⡷
⠶⣶⣶⣶⣾⣿⣿⣿⣷⣶⣶⣶⠶  ⣸⣿⡟ ⠀⢠⣿⣿⠃⠈⣿⣿⠀⣿⣿⢠⣿⡿⠀⣿⣿⣧⣤⠀⢸⣿⡇⣠⣿⡿⠀⢠⣿⡟⣿⣿⠀⢸⣿⡿⠀⠀⣿⣿⠃⠀⢸⣿⣧⣄
⠀⠀⠙⢻⣿⣿⣿⣿⣿⡟⠋⠁⠀⠀ ⣿⣿⡇⠀ ⢸⣿⣿⠀⣸⣿⡟⠀⣿⣿⣾⡿⠁ ⣿⣿⠛⠛⠀⣿⣿⢿⣿⣏⠀⢀⣿⣿⣁⣿⣿⠀⣾⣿⡇⠀⢸⣿⡿⠀⠀⡀⠙⣿⣿⡆
⠀⠀⢠⣿⣿⣿⠿⣿⣿⣿⡄⠀⠀⠀ ⠙⢿⣿⣿⠇⠈⠿⣿⣿⡿⠋⠀⠀⢿⣿⡿⠁⠀⢸⣿⣿⣿⡇⢸⣿⣿⠀⣿⣿⣄⣾⣿⠛⠛⣿⣿⢠⣿⣿⣿ ⣼⣿⣿⣿ ⣿⣿⡿⠋⠀
⠀⢀⣾⠟⠋⠀⠀⠀⠙⠻⣷⡀⠀⠀
```

# Coveralls Universal Reporter ![GitHub Action](https://github.com/coverallsapp/coverage-reporter/workflows/Build/badge.svg)

Auto-detects your coverage artifact files and CI environment to post to [Coveralls.io](https://coveralls.io).

## Usage:

```
$ coveralls -h
Coveralls Coverage Reporter v0.1.5
Usage coveralls [arguments]
    -rTOKEN, --repo-token=TOKEN      Sets coveralls repo token, overrides settings in yaml or environment variable
    -cPATH, --config-path=PATH       Set the coveralls yaml config file location, will default to check '.coveralls.yml'
    -fFILENAME, --file=FILENAME      Coverage artifact file to be reported, e.g. coverage/lcov.info (detected by default)
    -jFLAG, --job-flag=FLAG          Coverage job flag name, e.g. Unit Tests
    -p, --parallel                   Set the parallel flag. Requires webhook for completion (coveralls --done).
    -d, --done                       Call webhook after all parallel jobs (-p) done.
    -n, --no-logo                    Do not show Coveralls logo in logs
    -q, --quiet                      Suppress all output
    -h, --help                       Show this help
```

## CI Usage Examples:

* CircleCI workflow.yml:

```yaml
- run: wget -cq https://coveralls.io/coveralls-linux.tar.gz -O - | tar -xz && ./coveralls
```

## Supported Coverage File Types:

* Lcov
* SimpleCov

Coming soon:

* Pytest-Cov
* Gcov

## Auto-Configuration Supported CIs:

* CircleCI
* Travis

[Docs on environment variables for other CI support.](https://docs.coveralls.io/supported-ci-services#insert-your-ci-here)

## Coveralls Enterprise

Set this environment variable to your instance's host:

`COVERALLS_ENDPOINT=https://coveralls-enterprise.example.com`

SSL check will be automatically disabled to allow self-signed certificates.

More info: [https://enterprise.coveralls.io](https://enterprise.coveralls.io)

---

# Development

To get started you will need crystal [installed](https://crystal-lang.org/install/) on your machine and then you can run:

```bash
shards install
make # dist/coverals will be created
```

Run specs:

```bash
make test
```

Self-contained binary compiling:

```bash
make release_mac # dist/coverals-mac.tar.gz will be created
make release_linux # (Docker must be running) dist/coverals-linux.tar.gz will be created
make release # both
```

# Release

1) Bump version in `coverage_reporter.cr` and `shards.yml`
2) Commit, Push
3) Run `make release` (Docker must be running)
4) Create a new release on GitHub
5) Upload `dist/coverals-mac.tar.gz` and `dist/coverals-linux.tar.gz` to the Release Attachments