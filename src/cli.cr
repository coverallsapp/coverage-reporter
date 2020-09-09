require "option_parser"
require "./coverage_reporter"
require "colorize"

filename = ""
repo_token = ENV.fetch("COVERALLS_REPO_TOKEN", "")
config_path = CoverageReporter::Config::DEFAULT_LOCATION
job_flag = ""
no_logo = false
parallel = false
parallel_finished = false

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

  parser.on("-p", "--parallel", "Set the parallel flag. Requires webhook for completion.") do
    parallel = true
  end

  parser.on("-f", "--finished", "Calls webhook after all parallel jobs finished.") do
    parallel_finished = true
  end

  parser.on("-n", "--no-logo", "Do not show Coveralls logo in logs") do 
    no_logo = true
  end

  parser.on("-h", "--help", "Show this help") do
    # TODO: add environment variable notes
    puts parser
    puts "Coveralls Coverage Reporter v#{CoverageReporter::VERSION}"
  end
end

begin
  unless no_logo
    puts " "
    puts " ⠀⠀⠀⠀⠀⠀#{"c".colorize(Colorize::Color256.new(88))}#{"o".colorize(Colorize::Color256.new(196))}#{"v".colorize(Colorize::Color256.new(88))}"
    puts " ⠀⠀⠀⠀⠀#{"e".colorize(Colorize::Color256.new(88))}#{"ral".colorize(Colorize::Color256.new(196))}#{"l".colorize(Colorize::Color256.new(88))}⠀⠀⠀⠀⠀⠀⠀ ⣠⣶⣾⣿⡇⢀⣴⣾⣿⣷⣆ ⣿⣿⠀⣰⣿⡟⢸⣿⣿⣿⡇ ⣿⣿⣿⣷⣦⠀⠀⢠⣿⣿⣿⠀⠀⣿⣿⠁⠀⣼⣿⡇⠀⢀⣴⣾⣿⡷"
    puts " #{"s".colorize(Colorize::Color256.new(88))}#{"coverallscove".colorize(Colorize::Color256.new(196))}#{"r".colorize(Colorize::Color256.new(88))}  ⣸⣿⡟ ⠀⢠⣿⣿⠃⠈⣿⣿⠀⣿⣿⢠⣿⡿⠀⣿⣿⣧⣤⠀⢸⣿⡇⣠⣿⡿⠀⢠⣿⡟⣿⣿⠀⢸⣿⡿⠀⠀⣿⣿⠃⠀⢸⣿⣧⣄"
    puts " ⠀⠀#{"a".colorize(Colorize::Color256.new(88))}#{"llscovera".colorize(Colorize::Color256.new(196))}#{"l".colorize(Colorize::Color256.new(88))}⠀⠀  ⣿⣿⡇⠀ ⢸⣿⣿⠀⣸⣿⡟⠀⣿⣿⣾⡿⠁ ⣿⣿⠛⠛⠀⣿⣿⢿⣿⣏⠀⢀⣿⣿⣁⣿⣿⠀⣾⣿⡇⠀⢸⣿⡿⠀⠀⡀⠙⣿⣿⡆"
    puts "⠀ ⠀ #{"l".colorize(Colorize::Color256.new(88))}#{"sco".colorize(Colorize::Color256.new(196))}#{"v".colorize(Colorize::Color256.new(52))}#{"era".colorize(Colorize::Color256.new(196))}#{"l".colorize(Colorize::Color256.new(88))}⠀⠀ ⠀ ⠙⢿⣿⣿⠇⠈⠿⣿⣿⡿⠋⠀⠀⢿⣿⡿⠁⠀⢸⣿⣿⣿⡇⢸⣿⣿⠀⣿⣿⣄⣾⣿⠛⠛⣿⣿⢠⣿⣿⣿ ⣼⣿⣿⣿ ⣿⣿⡿⠋⠀"
    puts " ⠀ #{"l".colorize(Colorize::Color256.new(88))}#{"sc".colorize(Colorize::Color256.new(196))}#{"o".colorize(Colorize::Color256.new(88))}#{"ver".colorize(Colorize::Color256.new(52))}#{"a".colorize(Colorize::Color256.new(88))}#{"ll".colorize(Colorize::Color256.new(196))}#{"s".colorize(Colorize::Color256.new(88))}⠀⠀"
    puts " "
    puts "  v#{CoverageReporter::VERSION}\n\n"
  else
    puts "⭐️ Coveralls.io Coverage Reporter v#{CoverageReporter::VERSION}"
  end

  if parallel_finished
    CoverageReporter.parallel_finished(repo_token, config_path)
  else
    CoverageReporter.run(filename, repo_token, config_path, job_flag, parallel)
  end

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
