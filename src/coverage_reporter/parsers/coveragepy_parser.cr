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
            puts name, nums
          end
        end
      end
    end
  end
end
