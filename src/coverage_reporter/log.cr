module CoverageReporter
  # Console output manager.
  module Log
    extend self

    enum Level
      Error
      Info
      Debug
    end

    @@level = Level::Info

    def set(@@level : Level); end

    def debug(*args)
      log(Level::Debug, STDOUT, *args)
    end

    def info(*args)
      log(Level::Info, STDOUT, *args)
    end

    def error(*args)
      log(Level::Error, STDERR, *args)
    end

    private def log(level, io, *args)
      return if @@level < level

      io.puts *args
    end
  end
end
