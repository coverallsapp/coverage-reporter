require "./base_parser"

module CoverageReporter
  # Simplecov coverage format parser.
  #
  # See: [https://github.com/simplecov-ruby/simplecov](https://github.com/simplecov-ruby/simplecov)
  class SimplecovParser < BaseParser
    alias Coverage = Array(Int64?)
    alias Branches = Hash(String, Hash(String, Int64?))
    alias LinesAndBranches = Hash(String, Array(Int64?) | Branches)
    alias Timestamp = Int64
    alias FileStats = Hash(String, Coverage | LinesAndBranches)
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
          coverage = [] of Int64?
          branches = [] of Int64?

          case info
          when Coverage
            coverage = info
          when LinesAndBranches
            coverage = info["lines"].as(Coverage)
            if info["branches"]?
              info["branches"].as(Branches).each do |branch, branch_info|
                branch_number = 0
                line_number = branch.split(", ")[2].to_i64
                branch_info.each_value do |hits|
                  branch_number += 1
                  branches.push(line_number, 0, branch_number, hits)
                end
              end
            end
          end

          reports.push(
            FileReport.new(
              name: name,
              coverage: coverage,
              branches: branches,
              source_digest: BaseParser.source_digest(name),
              format: self.class.name,
            )
          )
        end
      end

      reports
    end
  end
end
