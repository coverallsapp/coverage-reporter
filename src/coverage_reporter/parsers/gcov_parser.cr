require "./base_parser"
require "digest"

module CoverageReporter
  class GcovParser < BaseParser
    COVERAGE_RE = Regex.new(
      "^\\s*([0-9]+|-|#####):\\s*([0-9]+):(.*)",
      Regex::CompileOptions::MATCH_INVALID_UTF # don't raise error against non-UTF chars
    )

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
      coverage = {} of Int64 => Int64?
      name : String? = nil
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
            name = val
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
        file_report(
          name: name,
          coverage: coverage.keys.sort!.map { |i| coverage[i]? },
        ),
      ]
    end
  end
end
