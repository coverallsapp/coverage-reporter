require "./coverage_reporter/*"

module CoverageReporter
  extend self

  VERSION = "0.1.8"

  def run(
    coverage_file : String?,
    repo_token : String?,
    yaml_file_location : String,
    job_flag : String?,
    parallel : Bool
  )
    yaml = YamlConfig.new(yaml_file_location)
    git = GitInfo.run
    source_files = Parser.new(coverage_file).parse
    api = Api::Jobs.new(repo_token, yaml, git, job_flag, parallel, source_files)

    api.send_request
  end

  def parallel_done(repo_token : String | Nil, yaml_file_location : String)
    yaml = YamlConfig.new(yaml_file_location)
    api = Api::Webhook.new(repo_token, yaml)

    api.send_request
  end
end
