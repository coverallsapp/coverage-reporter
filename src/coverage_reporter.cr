require "./coverage_reporter/*"


module CoverageReporter
  VERSION = "0.1.8"

  def self.run(coverage_file : String, repo_token : String | Nil, yaml_file_location : String, job_flag : String | Nil, parallel : Bool)
    yaml = YamlConfig.new(yaml_file_location)
    git = GitInfo.run
    source_files = Parser.new(coverage_file).parse
    api = Api::Poster.new(repo_token, yaml, git, job_flag, parallel, source_files)

    api.send_request
  end

  def self.parallel_done(repo_token : String | Nil, yaml_file_location : String)
    yaml = YamlConfig.new(yaml_file_location)
    api = Api::Webhook.new(repo_token, yaml)

    api.send_request
  end

  def self.quiet!
    @@quiet = true
  end

  def self.quiet?
    @@quiet
  end

  def self.debug!
    @@debug = true
  end

  def self.debug?
    @@debug
  end
end
