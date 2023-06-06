module CoverageReporter
  alias Hits = UInt64
  alias Line = UInt64

  # File coverage report entity for Coveralls API.
  class FileReport
    getter coverage, branches, format

    # Platform-dependant separator.
    # / - for POSIX
    # \ - for Windows
    #
    # See `Path::SEPARATORS`
    SEPARATOR = Path::SEPARATORS.first

    # Returns MD5 hashsum of a file.
    def self.source_digest(filename : String) : String | Nil
      return unless File.exists?(filename)

      Digest::MD5.hexdigest(File.read(filename))
    end

    def initialize(
      @name : String,
      @coverage : Array(Hits?),
      @branches : Array(Hits) | Nil = nil,
      @source_digest : String | Nil = nil,
      @format : String? = nil,
      @base_path : String? = nil
    )
    end

    def to_h : Hash(Symbol, String | Array(Hits?) | Array(Hits))
      {
        :name          => name,
        :coverage      => coverage,
        :branches      => branches,
        :source_digest => source_digest,
      }.compact
    end

    def name : String
      name = @name
      name = name.sub(Dir.current, "") if name.starts_with?(Dir.current)
      backslash_pwd = Dir.current.split(SEPARATOR).join('/')
      name = name.sub(backslash_pwd, "") if name.starts_with?(backslash_pwd)
      name = name.split(SEPARATOR).join('/')
      name = prepend_base_path(name)

      Path.posix(name).normalize.to_s.lstrip('/')
    end

    private def prepend_base_path(name)
      base_path = @base_path.to_s
      return name if base_path.blank?
      return name if File.exists?(name)
      return File.join(base_path, name) if Dir[base_path].empty?

      Dir[base_path].map { |dir| File.join(dir, name) }.each do |joined_name|
        return joined_name if File.exists?(joined_name)
      end

      File.join(base_path, name)
    end

    private def source_digest
      @source_digest || self.class.source_digest(name)
    end
  end
end
