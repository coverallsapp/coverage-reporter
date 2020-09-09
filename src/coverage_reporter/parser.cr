require "./parser_helpers/*"

module CoverageReporter
  class Parser
    @files : Array(String)
    alias SourceFilesType = Hash(Symbol, Array(Int32 | Nil) | String)

    def initialize(filenames : String)
      @files = [] of String

      if filenames == ""
        (Dir["**/*/lcov.info"] +
          Dir["**/*/*.lcov"] +
          Dir["**/*/.resultset.json"] +
          Dir["**/*/.coverage"]).each do |filename|

          unless filename =~ /node_modules|vendor/
            @files.push(filename)
            puts "🔍 Detected coverage file: #{filename}" unless CoverageReporter.quiet?
          end
        end

      else
        if File.exists?(filenames)
          puts "📄 Using coverage file: #{filenames}" unless CoverageReporter.quiet?
          @files = [filenames]
        else
          puts "🚨 ERROR: Couldn't find specified file: #{filenames}"
          exit 1
        end
      end
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
        ParserHelpers::Lcov.new(filename).parse

      when /\.resultset\.json$/
        ParserHelpers::SimpleCov.new(filename).parse

      # when /$\.gcov/
      #   ParserHelpers::Gcov.new(filename).parse

      # when /\.coverage/
      #   ParserHelpers::PythonCov.new(filename).parse

      else
        puts "ERROR, coverage reporter does not yet know how to process this file: #{filename}"
        [] of SourceFilesType
      end
    end
  end
end
