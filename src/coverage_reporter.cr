require "./coverage_reporter/*"


module CoverageReporter
  VERSION = "0.1.0"

  def self.run(coverage_file : String, repo_token : String | Nil, yaml_file_location : String)
    yaml = YamlConfig.new(yaml_file_location)
    git = GitInfo.run
    source_files = LcovParser.new(coverage_file).parse
    puts source_files
    # api = Api.new(repo_token, yaml, git, source_files)

    #api.send_request
  end
end
