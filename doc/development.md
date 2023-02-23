# Development

> Notes for developers and maintainers

## Add coverage format support

Checklist to add a parser for a coverage report format:

1. Create a parser class which inherits `CoverageReporter::BaseParser`

```crystal
# Template parser.
#
# src/coverage_reporter/parsers/my_parser.cr

require "./base_parser"

module CoverageReporter
  class MyParser < BaseParser
    # Use *base_path* to append to file names retrieved from the coverage report.
    def initialize(@base_path : String)
    end

    # Returns array of globs for automatic coverage report detection.
    def globs : Array(String)
      ["**/*/*.mycov", "*.mycov"]
    end

    # Checks whether the *filename* can be parsed with this parser.
    def matches?(filename : String) : Bool
      filename.ends_with?(".mycov")
    end

    def parse(filename : String) : Array(FileReport)
      # ... format-specific parsing
    end
  end
end
```

2. Add your class to `CoverageReporter::Parser::PARSERS`

```crystal
# src/coverage_reporter/parser.cr

module CoverageReporter
  class Parser
    PARSERS = {
      # ...
      MyParser,
    }

    # ...
  end
end
```

3. Add specs

```crystal
# spec/coverage_reporter/parsers/my_parser_spec.cr

require "../../spec_helper"

Spectator.describe CoverageReporter::MyParser do
  subject { described_class.new }

  describe "#matches?" do
    # ...
  end

  describe "#parse" do
    # ...
  end
end
```

4. Test it

```bash
make
dist/coveralls --repo-token=<...> --file coverage/coverage.mycov
```

### Parser design

`CoverageReporter::BaseParser` provides a strict interface that needs to be implemented in order to parse coverage reports correctly and convert the report format into the data Coveralls API would understand. That's why the `#parser` method returns an array of `FileReport`, not just an array of `Hash`.

## Support new CI options

Checklist to add new CI options:

- Add a module at [src/coverage_reporter/ci/](../src/coverage_reporter/ci/) and implement `.options` method.
- Note: `.options` method should return `nil` if environment doesn't match the CI.
- Provide as many options as you can (see [`CI::Options`](../src/coverage_reporter/ci/options.cr) for the full list).
- Add your module to `CI_OPTIONS` tuple.
- Write the specs for your CI options.
