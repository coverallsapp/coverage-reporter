require "./base_parser"

module CoverageReporter
  class LcovParser < BaseParser
    alias LineInfo = Hash(Int32, Int32)
    alias BranchInfo = Hash(Int32, LineInfo)
    record Info,
      coverage : LineInfo,
      branches : Hash(Int32, BranchInfo)

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
      reports = [] of FileReport

      lcov_info(filename).each do |name, info|
        reports << report(name, info)
      end

      reports
    end

    private def lcov_info(filename : String) : Hash(String, Info)
      info = Hash(String, Info).new do |h, k|
        h[k] = Info.new(
          coverage: {} of Int32 => Int32,
          branches: {} of Int32 => BranchInfo,
        )
      end

      source_file = nil : String?
      File.each_line(filename, chomp: true) do |line|
        case line
        when /\ASF:(.+)/
          source_file = $1
        when /\ADA:(\d+),(\d+)/
          line_no = $1.to_i
          count = $2.to_i
          coverage = info[source_file].coverage
          coverage[line_no] = (coverage[line_no]? || 0) + count
        when /\ABRDA:(\d+),(\d+),(\d+),(\d+|-)/
          line_no = $1.to_i
          block_no = $2.to_i
          branch_no = $3.to_i
          hits = $4 == "-" ? 0 : $4.to_i

          branches = info[source_file].branches
          branches_line = branches[line_no] =
            branches[line_no]? || {} of Int32 => LineInfo
          branches_block = branches_line[block_no] =
            branches_line[block_no]? || {} of Int32 => Int32
          branches_block[branch_no] = (branches_block[branch_no]? || 0) + hits
        when /\Aend_of_record/
          source_file = nil
        end
      end

      info
    rescue ex
      puts "Could not process tracefile: #{filename}"
      puts "#{ex.class}: #{ex.message}"
      exit(1)
    end

    private def report(filename, info)
      lines = 0
      File.each_line(filename) { lines += 1 }

      coverage = Array(Int32?).new(lines, 0)
      lines.times do |index|
        coverage[index] = info.coverage[index + 1]?
      end

      branches = nil : Array(Int32?) | Nil
      unless info.branches.empty?
        branches = [] of Int32?
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
      )
    end
  end
end
