require "./base_parser"
require "xml"

module CoverageReporter
  class CoberturaParser < BaseParser
    record Info,
      coverage : Hash(Int64, Int64),
      branches : Hash(Int64, Array(Int64))

    # NOTE: Provide the base path for the sources. You can check "filename" in
    #       coverage report and see what part is missing to get a valid source path.
    def initialize(@base_path : String?)
    end

    def globs : Array(String)
      [
        "**/*/cobertura.xml",
        "cobertura.xml",
        "**/*/coverage.xml",
        "coverage.xml",
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
          coverage: {} of Int64 => Int64,
          branches: {} of Int64 => Array(Int64),
        )
      end

      xml.xpath_nodes("/coverage//class").each do |node|
        name = node.attributes["filename"].content
        coverage = Hash(Int64, Int64).new { |hh, kk| hh[kk] = 0 }
        branches = Hash(Int64, Array(Int64)).new { |hh, kk| hh[kk] = [] of Int64 }

        node.xpath_nodes("lines/line").each do |line_node|
          if line_node.attributes["branch"]?.try(&.content) == "true"
            branches[line_node.attributes["number"].content.to_i64] <<
              line_node.attributes["hits"].content.to_i64
          end

          coverage[line_node.attributes["number"].content.to_i64] =
            line_node.attributes["hits"].content.to_i64
        end

        files[name].coverage.merge!(coverage)
        files[name].branches.merge!(branches)
      end

      files.map do |name, info|
        branch_number : Int64 = 0

        path = File.join(@base_path.to_s, name)
        FileReport.new(
          name: path,
          coverage: (1..(info.coverage.keys.max? || 0)).map { |n| info.coverage[n]? },
          source_digest: BaseParser.source_digest(path),
          branches: info.branches.keys.sort!.flat_map do |line|
            branch = -1.to_i64
            info.branches[line].flat_map do |hits|
              branch_number += 1
              branch += 1
              [line, branch_number, branch, hits]
            end
          end,
          format: self.class.name,
        )
      end
    end
  end
end
