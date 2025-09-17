require "./base_parser"
require "xml"

module CoverageReporter
  class CoberturaParser < BaseParser
    record Info,
      coverage : Hash(Line, Hits?),
      branches : Hash(Line, Array(Hits))

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
          if line_node.attributes["branch"]?.try(&.content) == "true"
            branches[line_node.attributes["number"].content.to_u64] <<
              line_node.attributes["hits"].content.to_u64
          end

          coverage[line_node.attributes["number"].content.to_u64] =
            line_node.attributes["hits"].content.to_u64
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
            (1..max_line.to_i32).map { |n| info.coverage[n.to_u64]? }
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
  end
end
