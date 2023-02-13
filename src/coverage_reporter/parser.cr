require "./parsers/*"

module CoverageReporter
  # General parser that can do the following:
  # * Automatically find coverage report files.
  # * Parse coverage report files and return the format that Coveralls API requires.
  #
  # New parsers can be easily added. See `BaseParser` for details.
  class Parser
    getter file : String?
    getter parsers : Array(BaseParser)

    # A list of available parsers.
    # See `CoverageReporter::BaseParser` for details.
    PARSERS = {
      LcovParser,
      SimplecovParser,
      CoberturaParser,
      GcovParser,
    }

    def initialize(@file : String?, base_path : String?)
      @parsers = PARSERS.map(&.new(base_path)).to_a
    end

    # Returns coverage report files that can be parsed by utility.
    def files : Array(String)
      if custom_file = file
        if !File.exists?(custom_file)
          puts "🚨 ERROR: Couldn't find specified file: #{custom_file}"
          exit 1
        end

        Log.info "📄 Using coverage file: #{custom_file}"
        return [custom_file]
      end

      files = [] of String
      Dir[parsers.flat_map(&.globs)].each do |filename|
        unless filename =~ /node_modules|vendor/
          files.push(filename)
          Log.info "🔍 Detected coverage file: #{filename}"
        end
      end

      files
    end

    def parse : Array(FileReport)
      files.flat_map do |filename|
        parse_file(filename)
      end
    end

    private def parse_file(filename : String)
      parsers.each do |parser|
        next unless parser.matches?(filename)

        return parser.parse(filename)
      end

      puts "ERROR, coverage reporter does not yet know how to process this file: #{filename}"
      [] of FileReport
    end
  end
end
