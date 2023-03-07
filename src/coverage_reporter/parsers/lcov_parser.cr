require "./base_parser"

module CoverageReporter
  class LcovParser < BaseParser
    alias LineInfo = Hash(Int64, Int64)
    alias BranchInfo = Hash(Int64, LineInfo)
    record Info,
      coverage : LineInfo,
      branches : Hash(Int64, BranchInfo)

    # Use *base_path* to join with paths found in reports.
    def initialize(@base_path : String?)
    end

    def globs : Array(String)
      [
        "*.lcov",
        "lcov.info",
        "**/*/lcov.info",
        "**/*/*.lcov",
      ]
    end

    def matches?(filename : String) : Bool
      filename.ends_with?(".lcov") || filename.ends_with?("lcov.info")
    end

    def parse(filename : String) : Array(FileReport)
      lcov_info(filename).compact_map do |name, info|
        next unless File.exists?(name)

        report(name, info)
      end
    end

    private def lcov_info(filename : String) : Hash(String, Info)
      info = Hash(String, Info).new do |h, k|
        h[k] = Info.new(
          coverage: {} of Int64 => Int64,
          branches: {} of Int64 => BranchInfo,
        )
      end

      base_path = @base_path
      source_file = nil : String?
      File.each_line(filename, chomp: true) do |line|
        case line
        when /\ASF:(.+)/
          source_file = base_path ? File.join(base_path, $1) : $1
        when /\ADA:(\d+),(\d+)/
          line_no = $1.to_i64
          count = $2.to_i64
          coverage = info[source_file].coverage
          coverage[line_no] = (coverage[line_no]? || 0.to_i64) + count
        when /\ABRDA:(\d+),(\d+),(\d+),(\d+|-)/
          line_no = $1.to_i64
          block_no = $2.to_i64
          branch_no = $3.to_i64
          hits = $4 == "-" ? 0 : $4.to_i64

          branches = info[source_file].branches
          branches_line = branches[line_no] =
            branches[line_no]? || {} of Int64 => LineInfo
          branches_block = branches_line[block_no] =
            branches_line[block_no]? || {} of Int64 => Int64
          branches_block[branch_no] = (branches_block[branch_no]? || 0.to_i64) + hits
        when /\Aend_of_record/
          source_file = nil
        end
      end

      info
    rescue ex
      Log.error "Could not process tracefile: #{filename}"
      Log.error "#{ex.class}: #{ex.message}"
      exit(1)
    end

    private def report(filename, info) : FileReport
      lines = 0
      File.each_line(filename) { lines += 1 }

      coverage = Array(Int64?).new(lines, 0)
      lines.times do |index|
        coverage[index] = info.coverage[index + 1]?
      end

      branches = nil : Array(Int64?) | Nil
      unless info.branches.empty?
        branches = [] of Int64?
        info.branches.each do |line, blocks|
          blocks.each do |block, branches_number|
            branches_number.each do |branch, hits|
              branches.push(line, block, branch, hits)
            end
          end
        end
      end

      FileReport.new(
        name: filename.sub(Dir.current, ""),
        coverage: coverage,
        branches: branches,
        source_digest: BaseParser.file_digest(filename),
      )
    end
  end
end
