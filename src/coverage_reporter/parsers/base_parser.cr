require "../file_report"

module CoverageReporter
  # TODO: add docstring
  abstract class BaseParser
    # TODO: add docstring
    abstract def globs : Array(String)

    # TODO: add docstring
    abstract def matches?(filename : String) : Bool

    # TODO: add docstring
    abstract def parse(filename : String) : Array(FileReport)
  end
end
