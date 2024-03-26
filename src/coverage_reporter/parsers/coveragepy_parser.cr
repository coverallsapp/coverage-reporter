require "./base_parser"
require "sqlite3"

module CoverageReporter
  class CoveragepyParser < BaseParser
    def self.name
      "python"
    end

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
      # If you have coverage installed with xml support do this
      # check the return value of run
      # Run can raise an error: io::error
      # Can use tmp file method 
      Process.run(command: "coverage xml --data-infile #{filename} -o /tmp/coverage.xml")
      parser = CoberturaParser.new(@base_path)
      parser.parse("tmp/coverage.xml")

      # else
      # bring back all the sql parser I deleted
      # or error? ask James
    end

    private def get_coverage(name : String, hits : Array(Hits)) : Array(Hits?)
      coverage = {} of Line => Hits?

      line_no = 1.to_u64
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
    rescue File::NotFoundError
      Log.error("Couldn't open file #{name}")

      [] of Hits?
    end
  end
end
