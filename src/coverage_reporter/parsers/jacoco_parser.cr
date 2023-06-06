require "xml"
require "./base_parser"

module CoverageReporter
  class JacocoParser < BaseParser
    record Info,
      coverage : Hash(Line, Hits),
      branches : Hash(Line, Array(Hits))

    def globs : Array(String)
      ["**/*/jacoco*.xml"]
    end

    def matches?(filename) : Bool
      File.each_line(filename) do |line|
        return true if /<!DOCTYPE.*jacoco/i.matches?(line)
        return true if /<report/.matches?(line)

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
          coverage: {} of Line => Hits,
          branches: {} of Line => Array(Hits),
        )
      end

      xml.xpath_nodes("/report/package").each do |node|
        dir = node.attributes["name"].content

        node.xpath_nodes("sourcefile").each do |sourcefile_node|
          file = sourcefile_node.attributes["name"].content
          name = "#{dir}/#{file}"
          coverage = Hash(Line, Hits).new { |hh, kk| hh[kk] = 0 }
          branches = Hash(Line, Array(Hits)).new { |hh, kk| hh[kk] = [] of Hits }

          sourcefile_node.xpath_nodes("line").each do |line_node|
            cb = line_node.attributes["cb"].content.to_u64
            mb = line_node.attributes["mb"].content.to_u64
            cnt = cb + mb
            if cnt > 0
              cnt.times do |i|
                branches[line_node.attributes["nr"].content.to_u64] << (i < cb ? 1u64 : 0u64)
              end
            end

            coverage[line_node.attributes["nr"].content.to_u64] =
              line_node.attributes["ci"].content.to_u64
          end

          files[name].coverage.merge!(coverage)
          files[name].branches.merge!(branches)
        end
      end

      files.map do |name, info|
        branch_number : Hits = 0

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
