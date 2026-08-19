require "./base_parser"
require "xml"

module CoverageReporter
  class CoberturaParser < BaseParser
    record Info,
      coverage : Hash(Line, Hits?),
      branches : Hash(Line, Array(Hits))

    # Reporters such as coverage.py and gcovr describe how many of a line's
    # branches were taken with a `condition-coverage="50% (1/2)"` attribute
    # instead of emitting one `<line>` per branch.
    CONDITION_COVERAGE_RE = /\((\d+)\/(\d+)\)/

    # Sanity limit for the branch count read out of `condition-coverage`, so a
    # malformed attribute cannot make us allocate an enormous array.
    MAX_BRANCHES_PER_LINE = 1024_u64

    def globs : Array(String)
      [
        "**/*/cobertura.xml",
        "cobertura.xml",
        "**/*/*coverage.xml",
        "*coverage.xml",
      ]
    end

    def matches?(filename) : Bool
      File.each_line(filename) do |line|
        return true if /<!DOCTYPE\s+coverage.*cobertura/.matches?(line)
        return true if /<coverage/.matches?(line)

        next if /\s*<\?xml\s+version=/.matches?(line)
        next if /\s*<!--/.matches?(line)

        return false
      end

      false
    rescue Exception
      false
    end

    def parse(filename) : Array(FileReport)
      xml = File.open(filename) do |file|
        XML.parse(file)
      end

      files = Hash(String, Info).new do |h, k|
        h[k] = Info.new(
          coverage: {} of Line => Hits?,
          branches: {} of Line => Array(Hits),
        )
      end

      xml.xpath_nodes("/coverage//class").each do |node|
        name = node.attributes["filename"].content
        coverage = Hash(Line, Hits?).new { |hh, kk| hh[kk] = 0 }
        branches = Hash(Line, Array(Hits)).new { |hh, kk| hh[kk] = [] of Hits }

        node.xpath_nodes("lines/line").each do |line_node|
          line_number = line_node.attributes["number"].content.to_u64
          line_hits = line_node.attributes["hits"].content.to_u64

          if line_node.attributes["branch"]?.try(&.content) == "true"
            branches[line_number].concat(branch_hits(line_node, line_hits))
          end

          coverage[line_number] = line_hits
        end

        files[name].coverage.merge!(coverage)
        files[name].branches.merge!(branches)
      end

      files.map do |name, info|
        branch_number : UInt64 = 0_u64

        # Build coverage array safely:
        # If there are no positive line numbers, return an empty array
        # to avoid constructing the invalid range (1..0).
        max_line = info.coverage.keys.max?
        coverage_array =
          if max_line && max_line > 0_u64
            # Crystal arrays take Int32 sizes; guard and convert explicitly.
            raise "Cobertura file has too-large line number: #{max_line}" if max_line > Int32::MAX.to_u64
            (1..max_line.to_i32).map { |line_num| info.coverage[line_num.to_u64]? }
          else
            [] of Hits?
          end

        file_report(
          name: name,
          coverage: coverage_array,
          branches: info.branches.keys.sort!.flat_map do |line|
            branch = 0_u64
            info.branches[line].flat_map do |hits|
              branch_number += 1_u64
              [line, branch_number, branch, hits]
            ensure
              branch += 1_u64
            end
          end,
        )
      end
    end

    # Returns one hit count per branch of the line.
    #
    # When the line carries a `condition-coverage` attribute we know how many
    # of its branches were taken, so we expand it into that many entries: the
    # taken ones keep the line's hit count, the rest are reported as missed.
    # `condition-coverage` does not say *which* branches were missed, only how
    # many, so the taken ones are listed first.
    #
    # Without the attribute we fall back to a single branch carrying the line's
    # hit count, which is how reporters that emit one `<line>` per branch
    # (for example scoverage) describe their data.
    private def branch_hits(line_node : XML::Node, line_hits : Hits) : Array(Hits)
      condition = line_node.attributes["condition-coverage"]?.try(&.content)
      match = condition.try { |value| CONDITION_COVERAGE_RE.match(value) }
      return [line_hits] if match.nil?

      taken = match[1].to_u64
      total = match[2].to_u64
      return [line_hits] if total.zero? || taken > total || total > MAX_BRANCHES_PER_LINE

      # A line cannot take a branch without being executed. If the report says
      # otherwise, trust the branch count and report the taken ones as hit.
      taken_hits = line_hits > 0 ? line_hits : 1_u64

      Array(Hits).new(total.to_i32) { |index| index < taken ? taken_hits : 0_u64 }
    end
  end
end
