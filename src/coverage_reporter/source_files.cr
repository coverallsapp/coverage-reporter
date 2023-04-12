require "./file_report"

module CoverageReporter
  class SourceFiles
    include Enumerable(FileReport)

    getter filenames

    delegate :each, to: @source_files

    def initialize(@source_files = [] of FileReport, filename : String? = nil)
      @filenames = [] of String
      @filenames << filename if filename
    end

    def add(reports : Array(FileReport) | Nil, filename : String)
      return unless reports

      @source_files += reports
      @filenames << filename
    end
  end
end
