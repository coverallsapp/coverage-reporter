require "./base_parser"
require "sqlite3"

module CoverageReporter
  class CoveragepyParser < BaseParser
    QUERY = <<-SQL
    SELECT file.path, line_bits.numbits
      FROM line_bits
    INNER JOIN file ON (line_bits.file_id = file.id)
    SQL

    def globs : Array(String)
      [
        ".coverage",
        "**/*/.coverage",
      ]
    end

    def matches?(filename : String) : Bool
      File.open(filename) do |f|
        f.read_at(0, 15) do |io|
          io.gets.try(&.downcase) == "sqlite format 3"
        end
      end
    rescue Exception
      false
    end

    def parse(filename : String) : Array(FileReport)
      lines = {} of String => Array(Int64)

      DB.open "sqlite3://#{filename}" do |db|
        db.query(QUERY) do |rs|
          rs.each do
            name = rs.read(String)
            numbits = rs.read(Slice(UInt8))
            nums = [] of Int64
            numbits.each_with_index do |byte, byte_i|
              8.times do |bit_i|
                if byte & (1 << bit_i) != 0
                  nums << (byte_i * 8 + bit_i).to_i64
                end
              end
            end
            lines[name] = nums
          end
        end
      end

      lines.map do |name, hits|
        coverage = get_coverage(name, hits)

        FileReport.new(
          name: name.sub(Dir.current, ""),
          coverage: coverage,
          source_digest: BaseParser.file_digest(name),
        )
      end
    end

    private def get_coverage(name : String, hits : Array(Int64)) : Array(Int64?)
      coverage = {} of Int64 => Int64?

      line_no = 1
      under_def = false
      docstring = false
      brackets = 0

      File.each_line(name, chomp: true) do |line|
        code = line.strip

        if code.ends_with?(/\(|\{|\[/)
          brackets += code.count("({[")
          brackets -= code.count(")}]")
        end

        if !docstring && code.starts_with?("\"\"\"")
          if under_def || hits.find { |i| i == line_no }
            docstring = true
            coverage[line_no] = nil
            next
          end
        end

        # docstring
        if docstring
          if code.ends_with?("\"\"\"")
            docstring = false
          end

          coverage[line_no] = nil
          next
        end

        # comment
        if code.starts_with?("#")
          coverage[line_no] = nil
          next
        end

        # a hit
        if hits.find { |i| i == line_no }
          coverage[line_no] = 1
          next
        end

        # inside brackets
        if brackets > 0
          coverage[line_no] = nil
          next
        end

        # empty string
        if code.empty?
          coverage[line_no] = nil
          next
        end

        coverage[line_no] = 0
      ensure
        line_no += 1

        if code
          if brackets > 0 && code.ends_with?(/\)|\}|\]/)
            brackets += code.count("({[")
            brackets -= code.count(")}]")
          end

          under_def = code.starts_with?("def ") || code.starts_with?("class ")
        end
      end

      coverage.keys.sort!.map { |k| coverage[k] }
    end
  end
end
