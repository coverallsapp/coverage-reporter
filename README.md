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

## Install

#### Linux

```bash
# You can omit '-C /usr/local/bin' argument to keep it in current directory
curl -L https://coveralls.io/coveralls-linux.tar.gz | tar -xz -C /usr/local/bin
```

#### MacOS

```bash
brew tap coverallsapp/coveralls
brew install coveralls
```

#### Windows

Bash:

```bash
curl -L https://github.com/coverallsapp/coverage-reporter/releases/latest/download/coveralls-windows.exe -o coveralls.exe
```

PowerShell:

```powershell
Invoke-WebRequest -Uri "https://github.com/coverallsapp/coverage-reporter/releases/latest/download/coveralls-windows.exe" -OutFile "coveralls.exe"
```

## Usage

> See also [environment variables list](./doc/configuration.md#env-variables) and [YAML config](./doc/configuration.md#yaml-config) that control the utility behavior.

```bash
# Automatic lookup for supported reports and sending them to https://coveralls.io
coveralls

# Provide explicit repo token
coveralls --repo-token=rg8ZznwNq05g3HDfknodmueeRciuiiPDE

# Use concrete report file
coveralls --file coverage/lcov.info

# Use parallel reports
coveralls --file project1/coverage/lcov.info --parallel
coveralls --file project2/coverage/lcov.info --parallel
# ...
coveralls --done

# Provide a job flag and use carry-forwarding
coveralls --job-flag "unit-tests" --parallel
coveralls --job-flag "integration-tests" --parallel
coveralls --done --carryforward "unit-tests,integration-tests"

# Testing options: no real reporting, print payload
coveralls --debug --dry-run
```

For more options see `coveralls -h/--help`

```
$ coveralls -h
Coveralls Coverage Reporter vX.Y.Z
Usage: coveralls [options]
    -rTOKEN, --repo-token=TOKEN      Sets coveralls repo token, overrides settings in yaml or environment variable
    -cPATH, --config-path=PATH       Set the coveralls yaml config file location, will default to check '.coveralls.yml'
    -bPATH, --base-path=PATH         Path to the root folder of the project the coverage was collected in
    -fFILENAME, --file=FILENAME      Coverage artifact file to be reported, e.g. coverage/lcov.info (detected by default)
    -jFLAG, --job-flag=FLAG          Coverage job flag name, e.g. Unit Tests
    -p, --parallel                   Set the parallel flag. Requires webhook for completion (coveralls --done).
    -cf, --carryforward              Comma-separated list of parallel job flags
    -d, --done                       Call webhook after all parallel jobs (-p) done.
    -n, --no-logo                    Do not show Coveralls logo in logs
    -q, --quiet                      Suppress all output
    --debug                          Debug mode. Data being sent to Coveralls will be outputted to console.
    --dry-run                        Dry run (no request sent)
    -v, --version                    Show version
    -h, --help                       Show this help
```

## CI Usage Examples

* CircleCI workflow.yml:

```yaml
- run: wget -cq https://coveralls.io/coveralls-linux.tar.gz -O - | tar -xz && ./coveralls
```

* Github Actions workflow.yml:

```yaml
- run: curl -L https://coveralls.io/coveralls-linux.tar.gz | tar -xz && ./coveralls
  env:
    COVERALLS_REPO_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Supported Coverage File Types

- [x] Lcov
- [x] SimpleCov
- [x] Cobertura
- [x] Jacoco
- [x] Gcov
- [x] Golang coverage format
- [ ] Pytest-Cov

You can add a report parser to this project by following [these instructions](./doc/development.md#add-coverage-format-support).

**Bounty**: One or more months of free service at Coveralls.io. <a target="_blank" href="mailto:support@coveralls.io?subject=Please tell me more about contributing to the Universal Coverage Reporter">Contact us</a> to learn more.

## Auto-Configuration Supported CIs

- CircleCI
- Github Actions
- Travis
- Jenkins
- GitLab
- Semaphore
- Wercker
- Codeship
- Drone
- Buildkite

[Docs on environment variables for other CI support.](https://docs.coveralls.io/supported-ci-services#insert-your-ci-here)

## Coveralls Enterprise

Set this environment variable to your instance's host:

```
COVERALLS_ENDPOINT=https://coveralls-enterprise.example.com
```

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

1. Bump version in [`src/coverage_reporter.cr`](./src/coverage_reporter.cr) and [`shard.yml`](./shard.yml)
2. Commit with a message `git commit --message "X.X.X: <short changes description>"`
3. Create a tag `git tag --sign --annotate vX.X.X` with the same annotation as commit message
4. Push with a tag `git push origin master --follow-tags`

Github release will be created automatically.
