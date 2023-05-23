require "./base_parser"

module CoverageReporter
  # Simplecov coverage format parser.
  #
  # See: [https://github.com/simplecov-ruby/simplecov](https://github.com/simplecov-ruby/simplecov)
  class SimplecovParser < BaseParser
    alias Coverage = Array(Int64?)

    class ComplexCoverage
      include JSON::Serializable

      property lines : Coverage
      property branches : Hash(String, Hash(String, Int64?)) | Nil
    end

    class Report
      include JSON::Serializable

      property coverage : Hash(String, Coverage | ComplexCoverage)
      property timestamp : Int64?
    end

    alias SimplecovReport = Hash(String, Report)

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

      data = SimplecovReport.from_json(File.read(filename))

      data.each do |_service, report|
        report.coverage.each do |name, info|
          coverage = [] of Int64?
          branches = [] of Int64?

          case info
          when Coverage
            coverage = info
          when ComplexCoverage
            coverage = info.lines
            info_branches = info.branches
            if info_branches
              info_branches.each do |branch, branch_info|
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
