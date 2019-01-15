module CoverageReporter
  class LcovParser
    def initialize(lcov_file)
      @tracefile = lcov_file
    end

    def parse
      source_files = [] of Hash

      lcov_info = parse_tracefile
      lcov_info.each do |filename, info|
        source_files << parse_sourcefile(filename, info)
      end

      source_files
    end

    private def parse_tracefile
      lcov_info = Hash.new do |h, k|
        h[k] = {
          "coverage" => {} of Int32 => Int32,
          "branches" => {} of Int32 => Int32,
        }
      end
      source_file = nil
      File.read_lines(@tracefile).each do |line|
        case line.chomp
        when /\ASF:(.+)/
          source_file = $1
        when /\ADA:(\d+),(\d+)/
          line_no = $1.to_i
          count = $2.to_i
          coverage = lcov_info[source_file]["coverage"]
          coverage[line_no] = (coverage[line_no] || 0) + count
        when /\ABRDA:(\d+),(\d+),(\d+),(\d+|-)/
          line_no = $1.to_i
          block_no = $2.to_i
          branch_no = $3.to_i
          hits = 0
          unless $4 == "-"
            hits = $4.to_i
          end
          branches = lcov_info[source_file]["branches"]
          branches_line = branches[line_no] = branches[line_no] || {} of Int32 => Int32
          branches_block = branches_line[block_no] = branches_line[block_no] || {} of Int32 => Int32
          branches_block[branch_no] = (branches_block[branch_no] || 0) + hits
        when /\Aend_of_record/
          source_file = nil
        end
      end
      lcov_info
    rescue ex
      warn "Could not read tracefile: #{@tracefile}"
      warn "#{ex.class}: #{ex.message}"
      exit(false)
    end
  end

  private def parse_sourcefile(filename, info)
    source = File.open(filename, "r:#{@source_encoding}", &:read).encode("UTF-8")
    lines = source.lines
    coverage = Array.new(lines.to_a.size)
    source.lines.each_with_index do |_line, index|
      coverage[index] = info["coverage"][index + 1]
    end
    top_src_dir = Dir.pwd
    source_file = {
      :name => filename.sub(top_src_dir, ""),
      :coverage => coverage,
    }
    unless info["branches"].empty?
      branches = [] of Array
      info["branches"].each do |line_no, blocks_no|
        blocks_no.each do |block_no, branches_no|
          branches_no.each do |branch_no, hits|
            branches.push(line_no, block_no, branch_no, hits)
          end
        end
      end
      source_file[:branches] = branches
    end
    source_file
  end
end
