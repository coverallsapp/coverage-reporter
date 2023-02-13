# Development

> Notes for developers and maintainers

## Support new coverage report format

Checklist to add support for a new coverage report format:

- Add a new implementation of `CoverageReporter::BaseParser` class.
- Add your class to `CoverageReporter::Parser::PARSERS` tuple.
- Write the specs for your parser.
- Test it locally.

### Parser design

`CoverageReporter::BaseParser` provides a strict interface that needs to be implemented in order to parse coverage reports correctly and convert the report format into the data Coveralls API would understand. That's why the `#parser` method returns an array of `FileReport`, not just an array of `Hash`.

## Support new CI options

Checklist to add new CI options:

- Add a module at [src/coverage_reporter/ci/](../src/coverage_reporter/ci/) and implement `.options` method.
- Note: `.options` method should return `nil` if utility is ran not in CI.
- Provide as many options as you can (see [`Options`](../src/coverage_reporter/ci/options.cr) for the full list).
- Add your module to `CI_OPTIONS` tuple.
- Write the specs for your CI options.
