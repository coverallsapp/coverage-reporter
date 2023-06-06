```
⠀⠀⠀⠀⠀⠀⣿
⠀⠀⠀⠀⠀⣼⣿⣧⠀⠀⠀⠀⠀⠀⠀ ⣠⣶⣾⣿⡇⢀⣴⣾⣿⣷⣆ ⣿⣿⠀⣰⣿⡟⢸⣿⣿⣿⡇ ⣿⣿⣿⣷⣦⠀⠀⢠⣿⣿⣿⠀⠀⣿⣿⠁⠀⣼⣿⡇⠀⢀⣴⣾⣿⡷
⠶⣶⣶⣶⣾⣿⣿⣿⣷⣶⣶⣶⠶  ⣸⣿⡟ ⠀⢠⣿⣿⠃⠈⣿⣿⠀⣿⣿⢠⣿⡿⠀⣿⣿⣧⣤⠀⢸⣿⡇⣠⣿⡿⠀⢠⣿⡟⣿⣿⠀⢸⣿⡿⠀⠀⣿⣿⠃⠀⢸⣿⣧⣄
⠀⠀⠙⢻⣿⣿⣿⣿⣿⡟⠋⠁⠀⠀ ⣿⣿⡇⠀ ⢸⣿⣿⠀⣸⣿⡟⠀⣿⣿⣾⡿⠁ ⣿⣿⠛⠛⠀⣿⣿⢿⣿⣏⠀⢀⣿⣿⣁⣿⣿⠀⣾⣿⡇⠀⢸⣿⡿⠀⠀⡀⠙⣿⣿⡆
⠀⠀⢠⣿⣿⣿⠿⣿⣿⣿⡄⠀⠀⠀ ⠙⢿⣿⣿⠇⠈⠿⣿⣿⡿⠋⠀⠀⢿⣿⡿⠁⠀⢸⣿⣿⣿⡇⢸⣿⣿⠀⣿⣿⣄⣾⣿⠛⠛⣿⣿⢠⣿⣿⣿ ⣼⣿⣿⣿ ⣿⣿⡿⠋⠀
⠀⢀⣾⠟⠋⠀⠀⠀⠙⠻⣷⡀⠀⠀
```

# Universal Coverage Reporter ![GitHub Action](https://github.com/coverallsapp/coverage-reporter/workflows/Build/badge.svg) [![Coverage Status](https://coveralls.io/repos/github/coverallsapp/coverage-reporter/badge.svg?branch=master)](https://coveralls.io/github/coverallsapp/coverage-reporter?branch=master)

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
<summary>For more options see <code>coveralls -h/--help</code></summary>

```
$ coveralls -h
Usage: coveralls [command] [options]
    report                           Report coverage
    done                             Close a parallel build
    version                          Print version
    --debug                          Debug mode: data being sent to Coveralls will be printed to console
    --dry-run                        Dry run (no request sent)
    -n, --no-logo                    Do not show Coveralls logo in logs
    -q, --quiet                      Suppress all output
    -h, --help                       Show this help
    -rTOKEN, --repo-token=TOKEN      Sets coveralls repo token, overrides settings in yaml or environment variable
    -cPATH, --config-path=PATH       Set the coveralls yaml config file location, will default to check '.coveralls.yml'

$ coveralls report -h
Usage: coveralls report [file reports] [options]
    --debug                          Debug mode: data being sent to Coveralls will be printed to console
    --dry-run                        Dry run (no request sent)
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

- [Github Actions](./doc/examples/github-actions.yml)
- [Github Actions (using `coverallsapp/github-action`)](./doc/examples/github-actions-default.yml)
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
- [x] Pytest-Cov ([:test_tube: beta](#pytest-cov-test_tube-beta)) - `python`

You can add a report parser to this project by following [these instructions](./doc/development.md#add-coverage-format-support).

**Bounty**: One or more months of free service at Coveralls.io. <a target="_blank" href="mailto:support@coveralls.io?subject=Please tell me more about contributing to the Universal Coverage Reporter">Contact us</a> to learn more.

#### Pytest-Cov (:test_tube: beta)

Since `.coverage` stores only covered lines coverage-reporter needs to parse Python code to get uncovered lines. Parsing is done in a pretty naive way, so the results might be different from actual especially for complicated and non-trivial code.

If coverage results are incorrect consider exporting `.coverage` to XML:

```bash
coverage xml # creates coverage.xml
coveralls -f coverage.xml
```

### Supported CI Services

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

# Deployment

Cutting new releases.

#### Auto (prefered)

```bash
$ make new_release
New version: 1.2.3
Brief description: new coverage report support

$ git push origin master --follow-tags
```

#### Manual

1. Bump version in [`src/coverage_reporter.cr`](./src/coverage_reporter.cr) and [`shard.yml`](./shard.yml)
2. Commit with a message `git commit --message "X.X.X: <short changes description>"`
3. Create a tag `git tag --annotate vX.X.X` with the same annotation as commit message
4. Push with a tag `git push origin master --follow-tags`

Github release will be created automatically.
