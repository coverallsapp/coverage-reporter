require "./coverage_reporter/*"


module CoverageReporter
  VERSION = "0.1.0"

  def self.run(coverage_file : String, repo_token : String | Nil, yaml_file_location : String)
    yaml = YamlConfig.new(yaml_file_location)
    git = GitInfo.run
    api = Api.new(repo_token, yaml, git, nil)

    api.send_request
  end
end
