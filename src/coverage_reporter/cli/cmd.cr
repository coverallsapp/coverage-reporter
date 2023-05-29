require "../../coverage_reporter"
require "option_parser"
require "colorize"

module CoverageReporter::Cli
  extend self

  def run(args = ARGV)
    opts = parse_args(args)
    greet(opts.no_logo?)

    reporter = CoverageReporter::Reporter.new(
      base_path: opts.base_path,
      carryforward: opts.carryforward,
      compare_ref: opts.compare_ref,
      compare_sha: opts.compare_sha,
      config_path: opts.config_path,
      coverage_file: opts.filename,
      coverage_format: opts.format,
      dry_run: opts.dry_run?,
      fail_empty: !opts.allow_empty?,
      job_flag_name: opts.job_flag_name,
      overrides: opts.overrides,
      parallel: opts.parallel?,
      repo_token: opts.repo_token,
    )

    if opts.parallel_done?
      reporter.parallel_done
    else
      reporter.report
    end

    reporter
  rescue ex : BaseException
    Log.error ex.message
    exit(ex.fail? ? 1 : 0)
  rescue ex : Socket::Error
    Log.error ex.message
    exit 1
  rescue ex : ArgumentError
    Log.error <<-ERROR
    Oops! #{ex.message}
    Coveralls Coverage Reporter v#{CoverageReporter::VERSION}
    ERROR
    exit 1
  rescue ex : Crest::InternalServerError
    Log.error "⚠️ Internal server error. Please contact Coveralls team."
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
    raise(ex) if opts.try(&.debug?)

    Log.error ex.inspect
    exit 1
  end

  private class Opts
    property filename : String?
    property format : String?
    property repo_token : String?
    property base_path : String?
    property carryforward : String? = ENV["COVERALLS_CARRYFORWARD_FLAGS"]?.presence
    property job_flag_name : String? = ENV["COVERALLS_FLAG_NAME"]?.presence
    property config_path = CoverageReporter::YamlConfig::DEFAULT_LOCATION
    property compare_ref : String? = ENV["COVERALLS_COMPARE_REF"]?.presence
    property compare_sha : String? = ENV["COVERALLS_COMPARE_SHA"]?.presence

    # Flags
    property? no_logo = false
    property? parallel = !!(ENV["COVERALLS_PARALLEL"]?.presence && !ENV["COVERALLS_PARALLEL"].in?(["false", "0"]))
    property? parallel_done = false
    property? dry_run = false
    property? debug = false
    property? allow_empty = false

    # CI options overrides
    property service_name : String?
    property service_job_id : String?
    property service_build_url : String?
    property service_job_url : String?
    property service_branch : String?
    property service_pull_request : String?

    def overrides : CI::Options
      CI::Options.new(
        service_name: service_name,
        service_job_id: service_job_id,
        service_build_url: service_build_url,
        service_job_url: service_job_url,
        service_branch: service_branch,
        service_pull_request: service_pull_request,
      )
    end
  end

  private def parse_args(args, opts = Opts.new)
    option_parser = OptionParser.new do |parser|
      parser.banner = "Usage: coveralls [options]"
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

      parser.on(
        "-bPATH",
        "--base-path=PATH",
        "Path to the root folder of the project the coverage was collected in"
      ) do |path|
        opts.base_path = path
      end

      parser.on("-fFILENAME", "--file=FILENAME", "Coverage artifact file to be reported, e.g. coverage/lcov.info (detected by default)") do |name|
        opts.filename = name.presence
      end

      parser.on("-jFLAG", "--job-flag=FLAG", "Coverage job flag name, e.g. Unit Tests") do |flag|
        opts.job_flag_name = flag.presence
      end

      parser.on("-p", "--parallel", "Set the parallel flag. Requires webhook for completion (coveralls --done)") do
        opts.parallel = true
      end

      parser.on("-d", "--done", "Call webhook after all parallel jobs (-p) done") do
        opts.parallel_done = true
      end

      parser.on("-n", "--no-logo", "Do not show Coveralls logo in logs") do
        opts.no_logo = true
      end

      parser.on("-q", "--quiet", "Suppress all output") do
        Log.set(Log::Level::Error)
      end

      parser.on("--format=FORMAT", "Force coverage file format, supported formats: #{Parser::PARSERS.map(&.name).join(", ")}") do |format|
        opts.format = format.presence
      end

      parser.on("--allow-empty", "Allow empty coverage results and exit 0") do
        opts.allow_empty = true
      end

      parser.on("--compare-ref=REF", "Git branch name to compare the coverage with") do |ref|
        opts.compare_ref = ref.presence
      end

      parser.on("--compare-sha=SHA", "Git commit SHA to compare the coverage with") do |sha|
        opts.compare_sha = sha.presence
      end

      parser.on("--carryforward=FLAGS", "Comma-separated list of parallel job flags") do |flags|
        opts.carryforward = flags
      end

      parser.on("--service-name=NAME", "Build service name override") do |service_name|
        opts.service_name = service_name.presence
      end

      parser.on("--service-job-id=ID", "Build job override") do |service_job_id|
        opts.service_job_id = service_job_id.presence
      end

      parser.on("--service-build-url=URL", "Build URL override") do |service_build_url|
        opts.service_build_url = service_build_url.presence
      end

      parser.on("--service-job-url=URL", "Build job URL override") do |service_job_url|
        opts.service_job_url = service_job_url.presence
      end

      parser.on("--service-branch=NAME", "Branch name override") do |service_branch|
        opts.service_branch = service_branch.presence
      end

      parser.on("--service-pull-request=NUMBER", "PR number override") do |service_pull_request|
        opts.service_pull_request = service_pull_request.presence
      end

      parser.on("--debug", "Debug mode: data being sent to Coveralls will be printed to console") do
        opts.debug = true
        Log.set(Log::Level::Debug)
      end

      parser.on("--dry-run", "Dry run (no request sent)") do
        opts.dry_run = true
      end

      parser.on("-v", "--version", "Show version") do
        puts VERSION
        exit 0
      end

      parser.on("-h", "--help", "Show this help") do
        # TODO: add environment variable notes
        puts "Coveralls Coverage Reporter v#{CoverageReporter::VERSION}"
        puts parser
        exit 0
      end
    end

    option_parser.parse(args)

    opts
  rescue ex : OptionParser::InvalidOption
    puts "⚠️ #{ex.message}"
    puts
    puts option_parser
    exit 1
  end

  private def greet(no_logo : Bool)
    Colorize.on_tty_only!

    if no_logo
      Log.info "⭐️ Coveralls.io Coverage Reporter v#{CoverageReporter::VERSION}"
    else
      Log.info " "
      Log.info "⠀⠀⠀⠀⠀⠀#{"⣿".colorize(Log::RED)}"
      Log.info "⠀⠀⠀⠀⠀#{"⣼⣿⣧".colorize(Log::RED)}⠀⠀⠀⠀⠀⠀⠀ ⣠⣶⣾⣿⡇⢀⣴⣾⣿⣷⣆ ⣿⣿⠀⣰⣿⡟⢸⣿⣿⣿⡇ ⣿⣿⣿⣷⣦⠀⠀⢠⣿⣿⣿⠀⠀⣿⣿⠁⠀⣼⣿⡇⠀⢀⣴⣾⣿⡷"
      Log.info "#{"⠶⣶⣶⣶⣾⣿⣿⣿⣷⣶⣶⣶⠶".colorize(Log::RED)}  ⣸⣿⡟ ⠀⢠⣿⣿⠃⠈⣿⣿⠀⣿⣿⢠⣿⡿⠀⣿⣿⣧⣤⠀⢸⣿⡇⣠⣿⡿⠀⢠⣿⡟⣿⣿⠀⢸⣿⡿⠀⠀⣿⣿⠃⠀⢸⣿⣧⣄"
      Log.info "⠀⠀#{"⠙⢻⣿⣿⣿⣿⣿⡟⠋⠁".colorize(Log::RED)}⠀⠀ ⣿⣿⡇⠀ ⢸⣿⣿⠀⣸⣿⡟⠀⣿⣿⣾⡿⠁ ⣿⣿⠛⠛⠀⣿⣿⢿⣿⣏⠀⢀⣿⣿⣁⣿⣿⠀⣾⣿⡇⠀⢸⣿⡿⠀⠀⡀⠙⣿⣿⡆"
      Log.info "⠀⠀#{"⢠⣿⣿⣿⠿⣿⣿⣿⡄".colorize(Log::RED)}⠀⠀⠀ ⠙⢿⣿⣿⠇⠈⠿⣿⣿⡿⠋⠀⠀⢿⣿⡿⠁⠀⢸⣿⣿⣿⡇⢸⣿⣿⠀⣿⣿⣄⣾⣿⠛⠛⣿⣿⢠⣿⣿⣿ ⣼⣿⣿⣿ ⣿⣿⡿⠋⠀"
      Log.info "⠀#{"⢀⣾⠟⠋⠀⠀⠀⠙⠻⣷⡀".colorize(Log::RED)}⠀⠀"
      Log.info " "
      Log.info "  v#{CoverageReporter::VERSION}\n\n"
    end
  end
end
