require "option_parser"
require "./coverage_reporter"
require "colorize"

filename = ""
repo_token = ENV.fetch("COVERALLS_REPO_TOKEN", "")
config_path = CoverageReporter::Config::DEFAULT_LOCATION
job_flag = ""

parser = OptionParser.parse do |parser|
  parser.banner = "Usage coveralls [arguments]"
  parser.on(
    "-rTOKEN",
    "--repo-token=TOKEN",
    "Sets coveralls repo token, overrides settings in yaml or environment variable"
    ) do |token|
      repo_token = token
    end

  parser.on(
    "-cPATH",
    "--config-path=PATH",
    "Set the coveralls yaml config file location, will default to check '.coveralls.yml'"
    ) do |path|
      config_path = path
    end

  parser.on("-fFILENAME", "--file=FILENAME ", "Coverage artifact file to be reported, e.g. coverage/lcov.info") do |name|
    filename = name
  end

  parser.on("-jFLAG", "--job-flag=FLAG", "Coverage job flag name, e.g. Unit Tests") do |flag|
    job_flag = flag
  end

  parser.on("-h", "--help", "Show this help") do
    # TODO: add environment variable notes
    puts parser
    puts "Coveralls Coverage Reporter v#{CoverageReporter::VERSION}"
  end
end

begin
  puts " "
  puts "⠀⠀⠀⠀⠀⠀#{"⣿".colorize(Colorize::Color256.new(196))}"
  puts "⠀⠀⠀⠀⠀#{"⣼⣿⣧".colorize(Colorize::Color256.new(196))}⠀⠀⠀⠀⠀⠀⠀ ⣠⣶⣾⣿⡇⢀⣴⣾⣿⣷⣆ ⣿⣿⠀⣰⣿⡟⢸⣿⣿⣿⡇ ⣿⣿⣿⣷⣦⠀⠀⢠⣿⣿⣿⠀⠀⣿⣿⠁⠀⣼⣿⡇⠀⢀⣴⣾⣿⡷"
  puts "#{"⠶⣶⣶⣶⣾⣿⣿⣿⣷⣶⣶⣶⠶".colorize(Colorize::Color256.new(196))}  ⣸⣿⡟ ⠀⢠⣿⣿⠃⠈⣿⣿⠀⣿⣿⢠⣿⡿⠀⣿⣿⣧⣤⠀⢸⣿⡇⣠⣿⡿⠀⢠⣿⡟⣿⣿⠀⢸⣿⡿⠀⠀⣿⣿⠃⠀⢸⣿⣧⣄"
  puts "⠀⠀#{"⠙⢻⣿⣿⣿⣿⣿⡟⠋⠁".colorize(Colorize::Color256.new(196))}⠀⠀ ⣿⣿⡇⠀ ⢸⣿⣿⠀⣸⣿⡟⠀⣿⣿⣾⡿⠁ ⣿⣿⠛⠛⠀⣿⣿⢿⣿⣏⠀⢀⣿⣿⣁⣿⣿⠀⣾⣿⡇⠀⢸⣿⡿⠀⠀⡀⠙⣿⣿⡆"
  puts "⠀⠀#{"⢠⣿⣿⣿⠿⣿⣿⣿⡄".colorize(Colorize::Color256.new(196))}⠀⠀⠀ ⠙⢿⣿⣿⠇⠈⠿⣿⣿⡿⠋⠀⠀⢿⣿⡿⠁⠀⢸⣿⣿⣿⡇⢸⣿⣿⠀⣿⣿⣄⣾⣿⠛⠛⣿⣿⢠⣿⣿⣿ ⣼⣿⣿⣿ ⣿⣿⡿⠋⠀"
  puts "⠀#{"⢀⣾⠟⠋⠀⠀⠀⠙⠻⣷⡀".colorize(Colorize::Color256.new(196))}⠀⠀"
  puts " "
  puts "  v#{CoverageReporter::VERSION}\n\n"

  CoverageReporter.run(filename, repo_token, config_path, job_flag)
rescue ex : ArgumentError
  STDERR.puts <<-ERROR
  Oops! #{ex.message}
  #{parser}
  Coveralls Coverage Reporter v#{CoverageReporter::VERSION}
  ERROR
rescue ex : Crest::UnprocessableEntity
  STDERR.puts <<-ERROR
  ---
  Error: #{ex.message}
  ---
  🚨 Oops! It looks like your request was not processible by Coveralls.
  This is often the is the result of an incorrectly set repo token.
  More info/troubleshooting here: https://docs.coveralls.io
  - 💛, Coveralls
  ERROR
end
