require "colorize"

module CoverageReporter
  # Console output manager.
  module Log
    extend self

    RED    = Colorize::Color256.new(196) # ff0000
    YELLOW = Colorize::Color256.new(220) # ffaf00

    enum Level
      Suppress
      Error
      Warning
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

    def warn(*args)
      log(Level::Warning, STDERR, *(args.try(&.map(&.to_s.colorize(YELLOW)))))
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
