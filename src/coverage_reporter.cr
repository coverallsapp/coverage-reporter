require "./coverage_reporter/*"

module CoverageReporter
  VERSION = "0.1.0"

  def self.run(coverage_file : String, repo_token : String | Nil, yaml_file_location : String)
    puts coverage_file
    puts repo_token
    puts YamlConfig.new(yaml_file_location)
    puts GitInfo.run
  end
end
