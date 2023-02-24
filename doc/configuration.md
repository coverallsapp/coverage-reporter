# Configuration

> Utility configuration


## ENV variables

These variables are always used if provided.

| Name                           | Description |
| ------------------------------ | ----------- |
| `COVERALLS_REPO_TOKEN`         | Repository token |
| `COVERALLS_SERVICE_NAME`       | The name of your build system. Retrieved automatically, but can be overwritten. |
| `COVERALLS_SERVICE_NUMBER`     | A number that uniquely identifies the build. |
| `COVERALLS_SERVICE_JOB_ID`     | An ID that uniquely identifies the build's job. |
| `COVERALLS_SERVICE_JOB_NUMBER` | A number that uniquely identifies the build's job. |
| `COVERALLS_GIT_BRANCH`         | Git branch name |
| `COVERALLS_GIT_COMMIT`         | Git commit hash |
| `COVERALLS_ENDPOINT`           | Coveralls API endpoint. Default: `https://coveralls.io` |
| `COVERALLS_RUN_AT`             | A date string for the time that the job ran in RFC 3339 format. Default: current timestamp. |
| `COVERALLS_FLAG_NAME`          | Job flag name, e.g. "Unit", "Functional", or "Integration". Will be shown in the Coveralls UI. |
| `COVERALLS_PARALLEL`           | set to true when running jobs in parallel, requires a completion webhook. More info here: https://docs.coveralls.io/parallel-build-webhook |
| `COVERALLS_CARRYFORWARD_FLAGS` | Comma separated list of parallel job flags to use carry-forwarding for. |

## YAML config

This config is optional.

Its values are used in favor of CI-specific options but can be overwritten with [COVERALLS_* ENVs](#env-variables).

```yml
# .coveralls.yml

# Repository token
repo_token: abcde12345

# Repository name
repo_name: myorg/myrepo

# The name of your build system
service_name: my-ci
```
