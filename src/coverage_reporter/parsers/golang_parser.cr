require "./base_parser"

module CoverageReporter
  class GolangParser < BaseParser
    COVERAGE_RE = /^[\w.]+\/[\w.]+\/[\w.]+\/(?:v\d+\/)?(.*\.go):(\d+)\.\d+,(\d+)\.\d+\s+\d+\s+(\d+)/

    def globs : Array(String)
      [] of String
    end

    def matches?(filename : String) : Bool
      return false unless File.exists?(filename)

      File.open(filename, "r") do |f|
        return true if f.gets.to_s.chomp == "mode: set"
        return true if COVERAGE_RE.matches?(f.gets.to_s)
      end

      false
    end

    def parse(filename : String) : Array(FileReport)
      coverage = Hash(String, Hash(Int64, Int64)).new do |h, k|
        h[k] = Hash(Int64, Int64).new do |hh, kk|
          hh[kk] = 0
        end
      end

      File.each_line(filename, chomp: true) do |line|
        next unless line

        match = COVERAGE_RE.match(line)
        next unless match

        name = match[1]
        line_no_start = match[2].to_i64
        line_no_end = match[3].to_i64
        hits = match[4].to_i64

        (line_no_start..line_no_end).each do |line_no|
          coverage[name][line_no] += hits
        end
      end

      coverage.map do |name, lines|
        FileReport.new(
          name: name,
          source_digest: BaseParser.file_digest(name),
          coverage: (1..lines.keys.max).map do |line_no|
            lines[line_no]?
          end,
        )
      end
    end
  end
end
