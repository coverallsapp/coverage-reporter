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

      check_for_coverage_executable(valid_file_exists)
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
        raise ParserError.new(error.to_s)
      end
    ensure
      begin
        tmpfile && tmpfile.delete
      rescue File::Error
      end
    end

    private def check_for_coverage_executable(valid_file_exists : Bool)
      return false unless valid_file_exists

      error = IO::Memory.new
      process_status = Process.run(
        command: "coverage --version",
        shell: true,
        error: error
      )

      if process_status.success?
        true
      else
        Log.debug error.to_s
        false
      end
    end
  end
end
