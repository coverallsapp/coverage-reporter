require "./base_parser"
require "digest"

module CoverageReporter
  class GcovParser < BaseParser
    COVERAGE_RE = Regex.new(
      "^\\s*([0-9]+|-|#####):\\s*([0-9]+):(.*)",
      Regex::CompileOptions::MATCH_INVALID_UTF # don't raise error against non-UTF chars
    )

    # Use *base_path* to join with paths found in reports.
    def initialize(@base_path : String?)
    end

    def globs : Array(String)
      [
        "*.gcov",
        "**/*/*.gcov",
      ]
    end

    def matches?(filename : String) : Bool
      filename.ends_with?(".gcov")
    end

    def parse(filename : String) : Array(FileReport)
      base_path = @base_path
      coverage = {} of Int64 => Int64?
      name : String? = nil
      source_digest : String? = nil
      File.each_line(filename, chomp: true) do |line|
        match = COVERAGE_RE.match(line).try(&.to_a)
        next if !match || !match.try(&.size) == 4

        count, number, text = match[1..3]
        next unless number && text && count

        number = number.to_i64

        if number == 0
          match = /([^:]+):(.*)$/.match(text).try(&.to_a)
          next if !match || match.try(&.size) < 2

          key, val = match[1..2]
          if key == "Source" && val
            name = base_path ? File.join(base_path, val) : val
            source_digest = BaseParser.source_digest(name)
          end
        else
          coverage[number - 1] = case count.strip
                                 when "-"
                                   nil
                                 when "#####"
                                   if text.strip == "}"
                                     nil
                                   else
                                     0.to_i64
                                   end
                                 else
                                   count.to_i64
                                 end
        end
      end

      return [] of FileReport unless name

      [
        FileReport.new(
          name: name,
          coverage: coverage.keys.sort!.map { |i| coverage[i]? },
          source_digest: source_digest,
          format: self.class.name,
        ),
      ]
    end
  end
end
