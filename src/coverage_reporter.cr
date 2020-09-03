require "./coverage_reporter/*"


module CoverageReporter
  VERSION = "0.1.1"

  def self.run(coverage_file : String, repo_token : String | Nil, yaml_file_location : String, job_flag : String | Nil)
    yaml = YamlConfig.new(yaml_file_location)
    git = GitInfo.run
    source_files = Parser.new(coverage_file).parse
    api = Api.new(repo_token, yaml, git, job_flag, source_files)

    api.send_request
  end
end
