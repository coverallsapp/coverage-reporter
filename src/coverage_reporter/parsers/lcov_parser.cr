require "./base_parser"

module CoverageReporter
  class LcovParser < BaseParser
    alias LineInfo = Hash(Line, Hits)
    alias BranchInfo = Hash(UInt32, Hash(UInt32, Hits))
    record Info,
      coverage : LineInfo,
      branches : Hash(Line, BranchInfo)

    SOURCE_FILE_RE     = Regex.new("\\ASF:(.+)", Regex::CompileOptions::MATCH_INVALID_UTF)
    LINE_COVERAGE_RE   = Regex.new("\\ADA:(\\d+),(\\d+)", Regex::CompileOptions::MATCH_INVALID_UTF)
    BRANCH_COVERAGE_RE = Regex.new("\\ABRDA:(\\d+),(\\d+),(\\d+),(\\d+|-)", Regex::CompileOptions::MATCH_INVALID_UTF)
    END_RE             = Regex.new("\\Aend_of_record", Regex::CompileOptions::MATCH_INVALID_UTF)

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
        next report(name, info) if File.exists?(name)

        Path[filename].parents.each do |parent|
          lcov_related = parent / name
          break report(lcov_related.to_s, info) if File.exists?(lcov_related)
        end
      end
    end

    private def lcov_info(filename : String) : Hash(String, Info)
      info = Hash(String, Info).new do |h, k|
        h[k] = Info.new(
          coverage: {} of Line => Hits,
          branches: {} of Line => BranchInfo,
        )
      end

      base_path = @base_path
      source_file = nil : String?
      File.each_line(filename, chomp: true) do |line|
        case line
        when SOURCE_FILE_RE
          source_file = base_path ? File.join(base_path, $1) : $1
        when LINE_COVERAGE_RE
          line_no = $1.to_u64
          count = $2.to_u64
          coverage = info[source_file].coverage
          coverage[line_no] = (coverage[line_no]? || 0u64) + count
        when BRANCH_COVERAGE_RE
          line_no = $1.to_u64
          block_no = $2.to_u32
          branch_no = $3.to_u32
          hits = $4 == "-" ? 0 : $4.to_u64

          branches = info[source_file].branches
          branches_line = branches[line_no] =
            branches[line_no]? || {} of UInt32 => Hash(UInt32, Hits)
          branches_block = branches_line[block_no] =
            branches_line[block_no]? || {} of UInt32 => Hits
          branches_block[branch_no] = (branches_block[branch_no]? || 0u64) + hits
        when END_RE
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
      lines = info.coverage.keys.max? || 0
      coverage = Array(Hits?).new(lines, 0)
      lines.times do |index|
        coverage[index] = info.coverage[index + 1]?
      end

      branches = nil : Array(Hits) | Nil
      unless info.branches.empty?
        branches = [] of Hits
        info.branches.each do |line, blocks|
          blocks.each do |block, branches_number|
            branches_number.each do |branch, hits|
              branches.push(line, block, branch, hits)
            end
          end
        end
      end

      file_report(
        name: filename,
        coverage: coverage,
        branches: branches,
      )
    end
  end
end
