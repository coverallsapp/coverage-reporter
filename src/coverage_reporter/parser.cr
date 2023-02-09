require "./parsers/*"

module CoverageReporter
  class Parser
    getter file : String | Nil

    PARSERS = {
      LcovParser.new,
      SimplecovParser.new,
    }

    def initialize(@file : String?)
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
      Dir[PARSERS.flat_map(&.globs)].each do |filename|
        unless filename =~ /node_modules|vendor/
          files.push(filename)
          Log.info "🔍 Detected coverage file: #{filename}"
        end
      end

      files
    end

    def parse : Array(FileReport)
      reports = [] of FileReport
      files.flat_map do |filename|
        parse_file(filename)
      end

      reports
    end

    private def parse_file(filename : String)
      PARSERS.each do |parser|
        next unless parser.matches?(filename)

        return parser.parse(filename)
      end

      puts "ERROR, coverage reporter does not yet know how to process this file: #{filename}"
      [] of FileReport
    end
  end
end
