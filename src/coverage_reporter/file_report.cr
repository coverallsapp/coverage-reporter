module CoverageReporter
  # File coverage report entity for Coveralls API.
  class FileReport
    getter name, coverage, branches, format

    # Platform-dependant separator.
    # / - for POSIX
    # \ - for Windows
    #
    # See `Path::SEPARATORS`
    SEPARATOR = Path::SEPARATORS.first

    def initialize(
      @name : String,
      @coverage : Array(Int64?),
      @branches : Array(Int64?) | Array(Int64) | Nil = nil,
      @source_digest : String | Nil = nil,
      @format : String? = nil
    )
    end

    def to_h : Hash(Symbol, String | Array(Int64?) | Array(Int64))
      {
        :name          => path,
        :coverage      => @coverage,
        :branches      => @branches,
        :source_digest => @source_digest,
      }.compact
    end

    private def path : String
      Path.posix(@name.sub(Dir.current, "").split(SEPARATOR).join('/')).normalize.to_s.lstrip('/')
    end
  end
end
