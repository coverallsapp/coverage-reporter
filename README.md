# Coveralls.io Universal Coverage Reporter

## Usage:

```bash
$ coveralls -h
Coveralls Coverage Reporter v0.1.4
Usage coveralls [arguments]
    -rTOKEN, --repo-token=TOKEN      Sets coveralls repo token, overrides settings in yaml or environment variable
    -cPATH, --config-path=PATH       Set the coveralls yaml config file location, will default to check '.coveralls.yml'
    -fFILENAME, --file=FILENAME      Coverage artifact file to be reported, e.g. coverage/lcov.info
    -jFLAG, --job-flag=FLAG          Coverage job flag name, e.g. Unit Tests
    -p, --parallel                   Set the parallel flag. Requires webhook for completion.
    -f, --finished                   Calls webhook after all parallel jobs finished.
    -n, --no-logo                    Do not show Coveralls logo in logs
    -q, --quiet                      Suppress all output
    -h, --help                       Show this help
```

## Examples:

* CircleCI workflow.yml:

```yaml
- run: wget -cq https://coveralls.io/coveralls-linux.tar.gz -O - | tar -xz && ./coveralls
```

## Supported Coverage File Types:

* Lcov
* SimpleCov

Coming soon:

* PyCov
* Gcov

---

# Development

To get started you will need crystal [installed](https://crystal-lang.org/install/) on your machine and then you can run:

```bash
shards install
make
```

Self-contained binary compiling:

```bash
make release_mac
make release_linux
```