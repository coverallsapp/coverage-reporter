require "./base_parser"
require "sqlite3"

module CoverageReporter
  class CoveragepyParser < BaseParser
    class ParserError < RuntimeError
    end

    def self.name
      "python"
    end

    def globs : Array(String)
      [
        ".coverage",
        "**/*/.coverage",
      ]
    end

    def matches?(filename : String) : Bool
      valid_file_exists = File.open(filename) do |f|
        f.read_at(0, 15) do |io|
          io.gets.try(&.downcase) == "sqlite format 3"
        end
      end

      valid_file_exists && check_for_coverage_executable
    rescue Exception
      false
    end

    def parse(filename : String, error : Process::Stdio = IO::Memory.new) : Array(FileReport)
      tmpfile = File.tempfile("coverage.xml")
      process_status = Process.run(
        command: "coverage xml --data-file #{filename} -o #{tmpfile.path}",
        shell: true,
        error: error
      )

      if process_status.success?
        parser = CoberturaParser.new(@base_path)
        parser.parse(tmpfile.path)
      else
        error_message =
          %Q|There was an error processing #{filename}: #{error}

To use the #{self.class.name} format, do one of the following:
1. Make sure that the coverage executable is available in the
   runner environment, or
2. Convert the .coverage file to a coverage.xml file by running
   `coverage xml`. Then pass the input option `format: cobertura`
   (for Coveralls GitHub Action or orb), or pass `--format=cobertura`
   if using the coverage reporter alone.
|
        raise ParserError.new(error_message)
      end
    ensure
      begin
        tmpfile && tmpfile.delete
      rescue File::Error
      end
    end

    private def check_for_coverage_executable
      error = IO::Memory.new
      process_status = Process.run(
        command: "coverage --version",
        shell: true,
        error: error
      )

      if process_status.success?
        true
      else
        Log.debug("☝️ Detected coverage format: #{self.class.name}, but error with coverage executable: #{error}")
        false
      end
    end
  end
end
