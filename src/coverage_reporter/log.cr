module CoverageReporter
  module Log
    extend self

    enum Level
      Error
      Info
      Debug
    end

    @@level = Level::Info

    def set(@@level : Level = Level::Info)
    end

    def debug(*args)
      return if @@level < Level::Debug

      puts *args
    end

    def info(*args)
      return if @@level < Level::Info

      puts *args
    end
  end
end
