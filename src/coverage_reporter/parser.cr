require "./parser_helpers/*"

module CoverageReporter
  class Parser
    @files : Array(String)
    alias SourceFilesType = Hash(Symbol, Array(Int32 | Nil) | String)

    def initialize(filenames : String)
      @files = [filenames]
    end

    def parse
      source_files = [] of SourceFilesType
      @files.each do |filename|
        parse_file(filename).each do |source|
          source_files.push source
        end
      end

      source_files
    end

    private def parse_file(filename : String)
      case filename
      when /\.lcov$|lcov\.info$/
        puts "LCOV detected."
        ParserHelpers::Lcov.new(filename).parse

      # when /$\.gcov/
      #   Gcov.new(filename).parse
      # when /\.resultset.json/
      #   SimpleCov.new(filename).parse
      # when /\.coverage/
      #   PythonCov.new(filename).parse
      else
        puts "ERROR, coverage reporter does not yet know how to process this file: #{filename}"
        [] of SourceFilesType
      end
    end
  end
end
