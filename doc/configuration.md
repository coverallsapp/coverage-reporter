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
| `COVERALLS_CARRYFORWARD_FLAGS` | Comma-separated list of parallel job flags to use carry-forwarding for. |

## A generic CI ENV variables

If CI wasn't detected, these ENV variables are used as a fallback. You can set them in your CI to provide appropriate options.

| Name                 | Description |
| -------------------- | ----------- |
| `CI_NAME`            | The name of your build system |
| `CI_BUILD_NUMBER`    | A number that uniquely identifies the build. |
| `CI_JOB_ID`          | An ID that uniquely identifies the build's job. |
| `CI_BUILD_URL`       | URL of the CI build. |
| `CI_BRANCH`          | Git branch name. |
| `CI_PULL_REQUEST`    | Pull request number. |
| `CI_COMMIT_ID`       | Git commit SHA. |
| `CI_AUTHOR_NAME`     | Git change author name. |
| `CI_AUTHOR_EMAIL`    | Git change author email. |
| `CI_COMMITTER_NAME`  | Git committer name. |
| `CI_COMMITTER_EMAIL` | Git committer email. |
| `CI_COMMIT_MESSAGE`  | Git commit message. |


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
