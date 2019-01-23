require "option_parser"
require "./coverage_reporter"

filename = ""
repo_token = ENV.fetch("COVERALLS_REPO_TOKEN", "")
config_path = CoverageReporter::Config::DEFAULT_LOCATION
job_flag = ""

parser = OptionParser.parse! do |parser|
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
    "Set the coveralls yaml config file location, will default to '.coveralls.yml'"
    ) do |path|
      config_path = path
    end

  parser.on("-fFILENAME", "--file=FILENAME ", "Coverage file to be reported") do |name|
    filename = name
  end

  parser.on("-jFLAG", "--job-flag=FLAG", "Coverage job flag name") do |flag|
    job_flag = flag
  end

  parser.on("-h", "--help", "Show this help") do
    puts parser
    puts "Coveralls Coverage Reporter v#{CoverageReporter::VERSION}"
  end
end

begin
  CoverageReporter.run(filename, repo_token, config_path, job_flag)
rescue ex : ArgumentError
  STDERR.puts <<-ERROR
  Oops! #{ex.message}
  #{parser}
  Coveralls Coverage Reporter v#{CoverageReporter::VERSION}
  ERROR
rescue ex : Crest::UnprocessableEntity
  STDERR.puts <<-ERROR


  Oops! It looks like your request was not processible by Coveralls.
  This is often the is the result of an incorrectly set repo token.
  ---
  ERROR
end
