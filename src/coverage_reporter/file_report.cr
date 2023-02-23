module CoverageReporter
  # File coverage report entity for Coveralls API.
  class FileReport
    getter name, coverage, branches

    def initialize(
      @name : String,
      @coverage : Array(Int64?),
      @branches : Array(Int64?) | Array(Int64) | Nil = nil
    )
    end

    def to_h : Hash(Symbol, String | Array(Int64?) | Array(Int64))
      {
        :name     => @name,
        :coverage => @coverage,
        :branches => @branches,
      }.compact
    end
  end
end
