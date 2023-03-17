require "../file_report"
require "digest"

module CoverageReporter
  # Coverage report parser interface.
  #
  # To add a new parser create a class in **src/coverage_reporter/parsers/** folder and
  # implement three required methods. For example, if you add a `mycov` parser the code
  # should look like this:
  # ```
  # require "./base_parser"
  #
  # module CoverageReporter
  #   class MycovParser < BaseParser
  #     def globs : Array(String)
  #       ["**/*/*.mycov"]
  #     end
  #
  #     def matches?(filename : String) : Bool
  #       filename.ends_with?(".mycov")
  #     end
  #
  #     def parse(filename : String) : Array(FileReport)
  #       # ... mycov format specific parsing
  #     end
  #   end
  # end
  # ```
  # Them add your parser class to `PARSERS` constant in `Parser` class.
  # ```
  # PARSERS = {
  #   # ...
  #   MycovParser,
  # }
  # ```
  #
  # Existing parsers can be used as a reference.
  abstract class BaseParser
    # Returns parser name which can be used to force resolve the parser.
    def self.name : String
      {{ @type.stringify.gsub(/(.*::)(\w+)Parser/, "\\2").downcase }}
    end

    # Returns MD5 hashsum of a file.
    def self.file_digest(filename : String) : String | Nil
      return unless File.exists?(filename)

      Digest::MD5.hexdigest(File.read(filename))
    end

    # Initializes the parser.
    #
    # *base_path* can be used to join with all paths in coverage report in order
    # to properly reference a file.
    def initialize(base_path : String? = nil)
    end

    # Returns an array of globs that will be used to look for coverage reports.
    abstract def globs : Array(String)

    # Checks if the file can be parsed with the parser.
    abstract def matches?(filename : String) : Bool

    # Parses the file and returns an array of `FileReport` which will be
    # sent to Coveralls API.
    abstract def parse(filename : String) : Array(FileReport)
  end
end
