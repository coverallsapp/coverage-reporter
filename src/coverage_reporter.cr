require "./coverage_reporter/*"


module CoverageReporter
  VERSION = "0.1.0"

  def self.run(coverage_file : String, repo_token : String | Nil, yaml_file_location : String)
    yaml = YamlConfig.new(yaml_file_location)
    config = Config.new(repo_token, yaml)

    puts coverage_file
    puts config.get_config
    puts yaml
    puts GitInfo.run
  end
end
