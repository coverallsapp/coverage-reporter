require "./base_parser"

module CoverageReporter
  class GolangParser < BaseParser
    COVERAGE_RE = Regex.new(
      "^[\\w.-]+\\/(?:[\\w.-]+\\/)?(?:[\\w.-]+\\/)?(?:v\\d+\\/)?(.*\\.go):(\\d+)\\.\\d+,(\\d+)\\.\\d+\\s+\\d+\\s+(\\d+)",
      Regex::CompileOptions::MATCH_INVALID_UTF # don't raise error agains non-UTF chars
    )

    def globs : Array(String)
      [] of String
    end

    def matches?(filename : String) : Bool
      return false unless File.exists?(filename)

      File.open(filename, "r") do |f|
        # 1st line can contain "mode:"
        2.times do
          return true if COVERAGE_RE.matches?(f.gets.to_s)
        end
      end

      false
    rescue Exception
      false
    end

    def parse(filename : String) : Array(FileReport)
      coverage = Hash(String, Hash(Line, Hits)).new do |h, k|
        h[k] = Hash(Line, Hits).new do |hh, kk|
          hh[kk] = 0
        end
      end

      File.each_line(filename, chomp: true) do |line|
        next unless line

        match = COVERAGE_RE.match(line)
        next unless match

        name = match[1]
        line_no_start = match[2].to_u64
        line_no_end = match[3].to_u64
        hits = match[4].to_u64

        (line_no_start..line_no_end).each do |line_no|
          coverage[name][line_no] += hits
        end
      end

      coverage.map do |name, lines|
        file_report(
          name: name,
          coverage: (1..(lines.keys.max? || 0)).map do |line_no|
            lines[line_no]?
          end,
        )
      end
    end
  end
end
