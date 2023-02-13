require "./base_parser"

module CoverageReporter
  # Simplecov coverage format parser.
  #
  # See: [https://github.com/simplecov-ruby/simplecov](https://github.com/simplecov-ruby/simplecov)
  class SimplecovParser < BaseParser
    alias Coverage = Array(Int32?)
    alias Stats = Hash(String, Array(Int32?))
    alias Timestamp = Int32
    alias FileStats = Hash(String, Coverage | Stats)
    alias SimplecovFormat = Hash(String, Hash(String, FileStats | Timestamp))

    def globs : Array(String)
      [
        ".resultset.json",
        "**/*/.resultset.json",
      ]
    end

    def matches?(filename : String) : Bool
      filename.ends_with?(".resultset.json")
    end

    def parse(filename : String) : Array(FileReport)
      reports = [] of FileReport

      data = SimplecovFormat.from_json(File.read(filename))

      data.each do |_service, output|
        output["coverage"].as(FileStats).each do |name, info|
          coverage = [] of Int32?

          case info
          when Coverage
            coverage = info
          when Stats
            coverage = info["lines"]
            # TODO: Handle branches
          end

          reports.push(
            FileReport.new(
              name: name.sub(Dir.current, ""),
              coverage: coverage,
            )
          )
        end
      end

      reports
    end
  end
end
