require "colorize"

module CoverageReporter
  # Console output manager.
  module Log
    extend self

    RED = Colorize::Color256.new(196)

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
      log(Level::Error, STDERR, *(args.try(&.map(&.to_s.colorize(RED)))))
    end

    private def log(level, io, *args)
      return if @@level < level

      io.puts *args
    end
  end
end
