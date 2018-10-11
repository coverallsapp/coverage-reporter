# TODO: Write documentation for `Coverage::Reporter`
require "option_parser"

filename = ""
repo_token = ENV.fetch("COVERALLS_REPO_TOKEN", "")

OptionParser.parse! do |parser|
  parser.banner = "Usage coveralls [arguments]"
  parser.on("-r", "--repo-token", "Sets coveralls repo token") do |token|
    repo_token = token
  end
  parser.on("-f", "--file", "Sets coverage file for reporting") do |name| 
    filename = name 
  end
  parser.on("-h", "--help", "Show this help") { puts parser }
end

module Coverage::Reporter
  VERSION = "0.1.0"

  # TODO: Put your code here
end
