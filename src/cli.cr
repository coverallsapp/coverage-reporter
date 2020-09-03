require "option_parser"
require "./coverage_reporter"

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
  puts <<-'STR'
     _____                         _ _
    / ____|                       | | |
   | |     _____   _____ _ __ __ _| | |___
   | |    / _ \ \ / / _ \ '__/ _` | | / __|
   | |___| (_) \ V /  __/ | | (_| | | \__ \
    \_____\___/ \_/ \___|_|  \__,_|_|_|___/

STR

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
  Oops! It looks like your request was not processible by Coveralls.
  This is often the is the result of an incorrectly set repo token.
  ---
  #{ex.message}
  ERROR
end
