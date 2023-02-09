require "../../coverage_reporter"
require "option_parser"
require "colorize"

module CoverageReporter::Cli
  extend self

  def run(args = ARGV)
    opts = parse_args(args)
    red = Colorize::Color256.new(196)
    if opts.no_logo?
      Log.info "⭐️ Coveralls.io Coverage Reporter v#{CoverageReporter::VERSION}"
    else
      Log.info " "
      Log.info "⠀⠀⠀⠀⠀⠀#{"⣿".colorize(red)}"
      Log.info "⠀⠀⠀⠀⠀#{"⣼⣿⣧".colorize(red)}⠀⠀⠀⠀⠀⠀⠀ ⣠⣶⣾⣿⡇⢀⣴⣾⣿⣷⣆ ⣿⣿⠀⣰⣿⡟⢸⣿⣿⣿⡇ ⣿⣿⣿⣷⣦⠀⠀⢠⣿⣿⣿⠀⠀⣿⣿⠁⠀⣼⣿⡇⠀⢀⣴⣾⣿⡷"
      Log.info "#{"⠶⣶⣶⣶⣾⣿⣿⣿⣷⣶⣶⣶⠶".colorize(red)}  ⣸⣿⡟ ⠀⢠⣿⣿⠃⠈⣿⣿⠀⣿⣿⢠⣿⡿⠀⣿⣿⣧⣤⠀⢸⣿⡇⣠⣿⡿⠀⢠⣿⡟⣿⣿⠀⢸⣿⡿⠀⠀⣿⣿⠃⠀⢸⣿⣧⣄"
      Log.info "⠀⠀#{"⠙⢻⣿⣿⣿⣿⣿⡟⠋⠁".colorize(red)}⠀⠀ ⣿⣿⡇⠀ ⢸⣿⣿⠀⣸⣿⡟⠀⣿⣿⣾⡿⠁ ⣿⣿⠛⠛⠀⣿⣿⢿⣿⣏⠀⢀⣿⣿⣁⣿⣿⠀⣾⣿⡇⠀⢸⣿⡿⠀⠀⡀⠙⣿⣿⡆"
      Log.info "⠀⠀#{"⢠⣿⣿⣿⠿⣿⣿⣿⡄".colorize(red)}⠀⠀⠀ ⠙⢿⣿⣿⠇⠈⠿⣿⣿⡿⠋⠀⠀⢿⣿⡿⠁⠀⢸⣿⣿⣿⡇⢸⣿⣿⠀⣿⣿⣄⣾⣿⠛⠛⣿⣿⢠⣿⣿⣿ ⣼⣿⣿⣿ ⣿⣿⡿⠋⠀"
      Log.info "⠀#{"⢀⣾⠟⠋⠀⠀⠀⠙⠻⣷⡀".colorize(red)}⠀⠀"
      Log.info " "
      Log.info "  v#{CoverageReporter::VERSION}\n\n"
    end

    if opts.parallel_done?
      CoverageReporter.parallel_done(opts.repo_token, opts.config_path)
    else
      CoverageReporter.run(opts.filename, opts.repo_token, opts.config_path, opts.job_flag, opts.parallel?)
    end
  rescue ex : BaseException | Socket::Error
    Log.error ex.message
    exit 1
  rescue ex : ArgumentError
    Log.error <<-ERROR
    Oops! #{ex.message}
    Coveralls Coverage Reporter v#{CoverageReporter::VERSION}
    ERROR
    exit 1
  rescue ex : Crest::UnprocessableEntity
    Log.error <<-ERROR
    ---
    Error: #{ex.message}
    Response: #{ex.response}
    ---
    🚨 Oops! It looks like your request was not processible by Coveralls.
    This is often the is the result of an incorrectly set repo token.
    More info/troubleshooting here: https://docs.coveralls.io
    - 💛, Coveralls
    ERROR
    exit 1
  rescue ex
    Log.error ex.inspect
    exit 1
  end

  private class Opts
    property filename : String?
    property job_flag : String?
    property repo_token : String?
    property config_path = CoverageReporter::Config::DEFAULT_LOCATION
    property? no_logo = false
    property? parallel = !!(ENV["COVERALLS_PARALLEL"]? && ENV["COVERALLS_PARALLEL"] != "false") || false
    property? parallel_done = false
  end

  private def parse_args(args, opts = Opts.new)
    OptionParser.parse do |parser|
      parser.banner = "Usage coveralls [arguments]"
      parser.on(
        "-rTOKEN",
        "--repo-token=TOKEN",
        "Sets coveralls repo token, overrides settings in yaml or environment variable"
      ) do |token|
        opts.repo_token = token.presence
      end

      parser.on(
        "-cPATH",
        "--config-path=PATH",
        "Set the coveralls yaml config file location, will default to check '.coveralls.yml'"
      ) do |path|
        next unless path.presence

        opts.config_path = path
      end

      parser.on("-fFILENAME", "--file=FILENAME", "Coverage artifact file to be reported, e.g. coverage/lcov.info (detected by default)") do |name|
        opts.filename = name.presence
      end

      parser.on("-jFLAG", "--job-flag=FLAG", "Coverage job flag name, e.g. Unit Tests") do |flag|
        opts.job_flag = flag.presence
      end

      parser.on("-p", "--parallel", "Set the parallel flag. Requires webhook for completion (coveralls --done).") do
        opts.parallel = true
      end

      parser.on("-d", "--done", "Call webhook after all parallel jobs (-p) done.") do
        opts.parallel_done = true
      end

      parser.on("-n", "--no-logo", "Do not show Coveralls logo in logs") do
        opts.no_logo = true
      end

      parser.on("-q", "--quiet", "Suppress all output") do
        Log.set(Log::Level::Error)
      end

      parser.on("--debug", "Debug mode. Data being sent to Coveralls will be outputted to console.") do
        Log.set(Log::Level::Debug)
      end

      parser.on("-h", "--help", "Show this help") do
        # TODO: add environment variable notes
        puts "Coveralls Coverage Reporter v#{CoverageReporter::VERSION}"
        puts parser
        exit 0
      end
    end

    opts
  end
end
