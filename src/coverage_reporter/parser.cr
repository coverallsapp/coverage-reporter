require "./parsers/*"

module CoverageReporter
  # General parser that can do the following:
  # * Automatically find coverage report files.
  # * Parse coverage report files and return the format that Coveralls API requires.
  #
  # New parsers can be easily added. See `BaseParser` for details.
  class Parser
    getter coverage_file : String?
    getter coverage_format : String?
    getter base_path : String?
    getter parsers : Array(BaseParser)

    # A list of available parsers.
    # See `CoverageReporter::BaseParser` for details.
    PARSERS = {
      LcovParser,
      SimplecovParser,
      CoberturaParser,
      JacocoParser,
      GcovParser,
      GolangParser,
      CoveragepyParser,
    }

    class NotFound < BaseException
      def initialize(@filename : String)
      end

      def message
        "🚨 ERROR: Couldn't find specified file: #{@filename}"
      end
    end

    class InvalidCoverageFormat < BaseException
      def initialize(@format : String?)
      end

      def message
        "🚨 Unsupported coverage format: #{@format}\n" \
        "Supported formats:\n  #{PARSERS.map(&.name).join("\n  ")}"
      end
    end

    def initialize(@coverage_file : String?, @coverage_format : String?, @base_path : String?)
      @parsers = PARSERS.map(&.new(@base_path)).to_a
    end

    # Returns coverage report files that can be parsed by utility.
    def files : Array(String)
      if custom_file = coverage_file
        if !File.exists?(custom_file)
          raise NotFound.new(custom_file)
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
      if coverage_format
        Log.info("✏️  Forced coverage format: #{coverage_format}")
        parser_class = PARSERS.find { |klass| klass.name == coverage_format }
        if parser_class
          parser = parser_class.new(base_path)
          return files.flat_map { |filename| parser.parse(filename) }
        else
          raise InvalidCoverageFormat.new(coverage_format)
        end
      end

      files.flat_map do |filename|
        parse_file(filename)
      end
    end

    private def parse_file(filename : String)
      parsers.each do |parser|
        next unless parser.matches?(filename)

        return parser.parse(filename)
      end

      Log.info "⚠️ Coverage reporter does not yet know how to process this file: #{filename}"
      [] of FileReport
    end
  end
end
