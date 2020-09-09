module CoverageReporter
  module ParserHelpers
    class Lcov
      alias SourceFilesType = Hash(Symbol, Array(Int32 | Nil) | String)

      alias BranchInfoHashContent = Hash(Int32, Hash(Int32, Int32))
      alias BranchInfoType = Hash(Int32, BranchInfoHashContent)

      def initialize(@tracefile : String)
      end

      def parse : Array(SourceFilesType)
        source_files = [] of SourceFilesType

        lcov_info = parse_tracefile
        lcov_info.each do |filename, info|
          source_files << parse_sourcefile(filename, info)
        end

        source_files
      end

      private def parse_tracefile
        begin
          lcov_info = Hash(String, NamedTuple(coverage: Hash(Int32, Int32), branches: BranchInfoType)).new do |h, k|
            h[k] = {
              coverage: {} of Int32 => Int32,
              branches: {} of Int32 => BranchInfoHashContent,
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
              coverage = lcov_info[source_file][:coverage]
              coverage[line_no] = (coverage[line_no]? || 0) + count
            when /\ABRDA:(\d+),(\d+),(\d+),(\d+|-)/
              line_no = $1.to_i
              block_no = $2.to_i
              branch_no = $3.to_i
              hits = $4 == "-" ? 0 : $4.to_i

              branches = lcov_info[source_file][:branches]
              branches_line = branches[line_no] = branches[line_no]? || {} of Int32 => Hash(Int32, Int32)
              branches_block = branches_line[block_no] = branches_line[block_no]? || {} of Int32 => Int32
              branches_block[branch_no] = (branches_block[branch_no]? || 0) + hits
            when /\Aend_of_record/
              source_file = nil
            end
          end
          lcov_info
        rescue ex
          puts "Could not process tracefile: #{@tracefile}"
          puts "#{ex.class}: #{ex.message}"
          raise ex
          exit(1)
        end
      end

      private def parse_sourcefile(filename, info, source_encoding = "utf-8")
        lines = File.read_lines(filename)

        coverage = Array(Int32 | Nil).new(lines.size, 0)
        lines.each_with_index do |_line, index|
          coverage[index] = info[:coverage][index + 1]? || nil
        end

        top_src_dir = Dir.current
        source_file = {
          :name => filename.sub(top_src_dir, ""),
          :coverage => coverage,
        }
        unless info[:branches].empty?
          branches = [] of Int32 | Nil
          info[:branches].each do |line_no, blocks_no|
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
  end
end