```
⠀⠀⠀⠀⠀⠀⣿
⠀⠀⠀⠀⠀⣼⣿⣧⠀⠀⠀⠀ ⠀⠀ ⣠⣶⣾⣿⡇⢀⣴⣾⣿⣷⣆ ⣿⣿⠀⣰⣿⡟⢸⣿⣿⣿⡇ ⣿⣿⣿⣷⣦⠀⠀⢠⣿⣿⣿⠀⠀⣿⣿⠁⠀⣼⣿⡇⠀⢀⣴⣾⣿⡷
⠶⣶⣶⣶⣾⣿⣿⣿⣷⣶⣶⣶⠶  ⣸⣿⡟ ⠀⢠⣿⣿⠃⠈⣿⣿⠀⣿⣿⢠⣿⡿⠀⣿⣿⣧⣤⠀⢸⣿⡇⣠⣿⡿⠀⢠⣿⡟⣿⣿⠀⢸⣿⡿⠀⠀⣿⣿⠃⠀⢸⣿⣧⣄
⠀⠀⠙⢻⣿⣿⣿⣿⣿⡟⠋⠁⠀⠀ ⣿⣿⡇⠀ ⢸⣿⣿⠀⣸⣿⡟⠀⣿⣿⣾⡿⠁ ⣿⣿⠛⠛⠀⣿⣿⢿⣿⣏⠀⢀⣿⣿⣁⣿⣿⠀⣾⣿⡇⠀⢸⣿⡿⠀⠀⡀⠙⣿⣿⡆
⠀⠀⢠⣿⣿⣿⠿⣿⣿⣿⡄⠀⠀⠀ ⠙⢿⣿⣿⠇⠈⠿⣿⣿⡿⠋⠀⠀⢿⣿⡿⠁⠀⢸⣿⣿⣿⡇⢸⣿⣿⠀⣿⣿⣄⣾⣿⠛⠛⣿⣿⢠⣿⣿⣿ ⣼⣿⣿⣿ ⣿⣿⡿⠋⠀
⠀⢀⣾⠟⠋⠀⠀⠀⠙⠻⣷⡀⠀⠀
```

# Universal Coverage Reporter

[![Build](https://github.com/coverallsapp/coverage-reporter/actions/workflows/build.yml/badge.svg)](https://github.com/coverallsapp/coverage-reporter/actions/workflows/build.yml)
[![Coverage Status](https://coveralls.io/repos/github/coverallsapp/coverage-reporter/badge.svg?branch=master)](https://coveralls.io/github/coverallsapp/coverage-reporter?branch=master)

Auto-detects your coverage artifact files and CI environment to post to [Coveralls.io](https://coveralls.io).

## Install

### Linux

#### For x86_64 Architecture

You can choose to download and install from either the generic Linux archive or the `x86_64`-specific archive.

To install the generic Linux binary (which is for `x86_64`):

```bash
curl -L https://coveralls.io/coveralls-linux.tar.gz | tar -xz -C /usr/local/bin
```

To install the `x86_64`-specific binary:

```bash
curl -L https://coveralls.io/coveralls-linux-x86_64.tar.gz | tar -xz -C /usr/local/bin
```

#### For aarch64 Architecture

To install the `aarch64` binary:

```bash
curl -L https://coveralls.io/coveralls-linux-aarch64.tar.gz | tar -xz -C /usr/local/bin
```

**Note**: You can omit the `-C /usr/local/bin` argument to keep the binary in the current directory.

### MacOS

```bash
brew tap coverallsapp/coveralls
brew install coveralls
```

### Windows

Bash

```bash
curl -L https://github.com/coverallsapp/coverage-reporter/releases/latest/download/coveralls-windows.exe -o coveralls.exe
```

PowerShell

```powershell
Invoke-WebRequest -Uri "https://github.com/coverallsapp/coverage-reporter/releases/latest/download/coveralls-windows.exe" -OutFile "coveralls.exe"
```

## Usage

See also [environment variables list](./doc/configuration.md#env-variables) and [YAML config](./doc/configuration.md#yaml-config) that control the utility behavior.

### Examples

```bash
# Automatic lookup for supported reports and sending them to https://coveralls.io
coveralls report

# Provide explicit repo token
coveralls report --repo-token=rg8ZznwNq05g3HDfknodmueeRciuiiPDE

# Use concrete report file
coveralls report coverage/lcov.info

# Use parallel reports (must reference the same build number)
coveralls report project1/coverage/lcov.info --parallel --build-number 1
coveralls report project2/coverage/lcov.info --parallel --build-number 1
# ...
coveralls done --build-number 1

# Provide a job flag and use carry-forwarding
coveralls report --job-flag "unit-tests" --parallel --build-number 2
coveralls report --job-flag "integration-tests" --parallel --build-number 2
coveralls done --carryforward "unit-tests,integration-tests" --build-number 2

# Testing options: no real reporting, print payload
coveralls report --debug --dry-run
```

<details>
<summary>For more options see <code>coveralls --help</code></summary>

```
$ coveralls -h
Usage: coveralls [command] [options]
    report                           Report coverage
    done                             Close a parallel build
    version                          Print version
    --debug                          Debug mode: data being sent to Coveralls will be printed to console
    --dry-run                        Dry run (no request sent)
    --no-fail                        Always exit with status 0
    -n, --no-logo                    Do not show Coveralls logo in logs
    -q, --quiet                      Suppress all output
    -h, --help                       Show this help
    -rTOKEN, --repo-token=TOKEN      Sets coveralls repo token, overrides settings in yaml or environment variable
    -cPATH, --config-path=PATH       Set the coveralls yaml config file location, will default to check '.coveralls.yml'

$ coveralls report -h
Usage: coveralls report [file reports] [options]
    --debug                          Debug mode: data being sent to Coveralls will be printed to console
    --dry-run                        Dry run (no request sent)
    --no-fail                        Always exit with status 0
    -n, --no-logo                    Do not show Coveralls logo in logs
    -q, --quiet                      Suppress all output
    -h, --help                       Show this help
    -rTOKEN, --repo-token=TOKEN      Sets coveralls repo token, overrides settings in yaml or environment variable
    -cPATH, --config-path=PATH       Set the coveralls yaml config file location, will default to check '.coveralls.yml'
    --build-number=ID                Build number
    -bPATH, --base-path=PATH         Path to the root folder of the project the coverage was collected in
    -jFLAG, --job-flag=FLAG          Coverage job flag name, e.g. Unit Tests
    -p, --parallel                   Set the parallel flag. Requires webhook for completion (coveralls done)
    --format=FORMAT                  Force coverage file format, supported formats: lcov, simplecov, cobertura, jacoco, gcov, golang, python
    --allow-empty                    Allow empty coverage results and exit 0
    --compare-ref=REF                Git branch name to compare the coverage with
    --compare-sha=SHA                Git commit SHA to compare the coverage with
    --service-name=NAME              Build service name override
    --service-job-id=ID              Build job override
    --service-build-url=URL          Build URL override
    --service-job-url=URL            Build job URL override
    --service-branch=NAME            Branch name override
    --service-pull-request=NUMBER    PR number override

$ coveralls done -h
Usage: coveralls done [options]
    --debug                          Debug mode: data being sent to Coveralls will be printed to console
    --dry-run                        Dry run (no request sent)
    -n, --no-logo                    Do not show Coveralls logo in logs
    -q, --quiet                      Suppress all output
    -h, --help                       Show this help
    -rTOKEN, --repo-token=TOKEN      Sets coveralls repo token, overrides settings in yaml or environment variable
    -cPATH, --config-path=PATH       Set the coveralls yaml config file location, will default to check '.coveralls.yml'
    --carryforward=FLAGS             Comma-separated list of parallel job flags
    --build-number=ID                Build number
```

</details>

### CI Examples

- [GitHub Actions](./doc/examples/github-actions.yml)
- [GitHub Actions (using `coverallsapp/github-action`)](./doc/examples/github-actions-default.yml)
- [Circle CI](./doc/examples/circleci.yml)
- [Circle CI (orb)](./doc/examples/circleci-orb.yml)

## Built-In Support

### Supported Coverage Report Formats

With values used for `--format` option:

- [x] Lcov - `lcov`
- [x] SimpleCov - `simplecov`
- [x] Cobertura - `cobertura`
- [x] Jacoco - `jacoco`
- [x] Gcov - `gcov`
- [x] Golang coverage format - `golang`
- [x] Coveralls JSON format - `coveralls`
- [x] Pytest-Cov - `python`
- [x] Clover XML as available via PHPUnit - `clover`

You can add a report parser to this project by following [these instructions](./doc/development.md#add-coverage-format-support).

**Bounty**: One or more months of free service at Coveralls.io. <a target="_blank" href="mailto:support@coveralls.io?subject=Please tell me more about contributing to the Universal Coverage Reporter">Contact us</a> to learn more.

### Supported CI Services

- CircleCI
- GitHub Actions
- Travis
- Jenkins
- GitLab
- Semaphore
- Wercker
- Codeship
- Drone
- Buildkite
- Xcode Cloud

[Docs on environment variables for other CI support.](https://docs.coveralls.io/ci-services#option-1-use-common-environment-variables)

## Extending Support

### New CI Services

#### Supporting your CI service

How to use the Reporter with an **officially-unsupported CI service**. See [instructions](./doc/configuration.md#a-generic-ci-env-variables).

#### Adding Support for a New CI Service

See [development instructions](./doc/development.md#support-new-ci-options) to add support for a new CI service.

### New Coverage Report Formats

#### Supporting Your Coverage Report Format

If your coverage report format is not one of the ones above (in [Supported Coverage Report Formats](#supported-coverage-report-formats)), you could try finding a library to convert your format into one of the supported formats.

Otherwise, if you want to use the Reporter, you could add support for your coverage report format.

#### Adding Support for New Coverage Report Formats

See [development instructions](./doc/development.md#add-coverage-format-support) to add support for a new coverage report format.

## Coveralls Enterprise

Set this environment variable to your instance's host:

```
COVERALLS_ENDPOINT=https://coveralls-enterprise.example.com
```

SSL check will be automatically disabled to allow self-signed certificates.

More info: [https://enterprise.coveralls.io](https://enterprise.coveralls.io)

## Development

To get started you will need crystal [installed](https://crystal-lang.org/install/) on your machine and then you can run:

```bash
shards install
make # bin/coveralls will be created
```

Run specs:

```bash
make test
```

### Setup Windows in Vagrant

```bash
vagrant up

# to re-run provision script
vagrant provision

# to access Windows VM
vagrant ssh
# type powershell<enter>
```

### Deployment

Cutting new releases.

#### Auto (prefered)

```bash
$ make new_version
New version: 1.2.3
Brief description: new coverage report support
```

**Note**: The `new_version` target takes care of the entire process of creating a new release, including tagging and pushing the release with `git push origin master --follow-tags`.

[After the release is available][github-releases], see [Homebrew
release](#homebrew-release) instructions.
#### Manual

1. Bump version in [`src/coverage_reporter.cr`](./src/coverage_reporter.cr) and [`shard.yml`](./shard.yml)
2. Commit with a message `git commit --message "X.X.X: <short changes description>"`
3. Create a tag `git tag --annotate vX.X.X` with the same annotation as commit message
4. Push with a tag `git push origin master --follow-tags`

GitHub release will be created automatically. [After the release is
available][github-releases], see [Homebrew release](#homebrew-release)
instructions.

[github-releases]: https://github.com/coverallsapp/coverage-reporter/releases
#### Homebrew release

In the [homebrew-coveralls repo][homebrew], a new PR will automatically get
created. Once the `brew test-bot` checks have passed, label the PR with the
`pr-pull` tag in order to make the release available through Homebrew.

[homebrew]: https://github.com/coverallsapp/homebrew-coveralls
