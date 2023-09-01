require "./base_parser"
require "xml"

module CoverageReporter
  class CloverParser < BaseParser
    record Info,
      coverage : Hash(Line, Hits?),
      branches : Hash(Line, Array(Hits))

    # NOTE: Provide the base path for the sources. You can check "filename" in
    #       coverage report and see what part is missing to get a valid source path.
    def initialize(@base_path : String?)
    end

    def globs : Array(String)
      [
        "**/*/clover.xml",
        "clover.xml",
      ]
    end

    def matches?(filename) : Bool
      return true if /clover.xml/.matches?(filename)

      File.each_line(filename) do |line|
        return true if /<coverage generated=/.matches?(line)
        next if /\s*<\?xml\s+version=/.matches?(line)
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

      xml.xpath_nodes("//file").each do |node|
        name = if node.attributes["path"]?
                 node.attributes["path"].content
               else
                 node.attributes["name"].content
               end
        coverage = Hash(Line, Hits?).new { |hh, kk| hh[kk] = 0 }
        branches = Hash(Line, Array(Hits)).new { |hh, kk| hh[kk] = [] of Hits }

        lines_nodes = node.xpath_nodes("line")
        lines_nodes.each do |line_node|
          line_number = line_node.attributes["num"].content.to_u64
          line_type = line_node.attributes["type"].content

          if line_type == "cond"
            branch_hits = line_node.attributes["truecount"].content.to_u64
            branches[line_number] << branch_hits
          end

          hits = line_node.attributes["count"].content.to_u64
          coverage[line_number] = hits
        end

        files[name].coverage.merge!(coverage)
        files[name].branches.merge!(branches)
      end

      files.map do |name, info|
        branch_number : UInt64 = 0

        file_report(
          name: name,
          coverage: (1..(info.coverage.keys.max? || 0)).map { |n| info.coverage[n]? },
          branches: info.branches.keys.sort!.flat_map do |line|
            branch = 0u64
            info.branches[line].flat_map do |hits|
              branch_number += 1
              [line, branch_number, branch, hits]
            ensure
              branch += 1
            end
          end,
        )
      end
    end
  end
end
