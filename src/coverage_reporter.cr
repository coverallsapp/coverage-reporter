require "./coverage_reporter/*"

module CoverageReporter
  extend self

  VERSION = "0.1.8"

  def run(
    coverage_file : String?,
    repo_token : String?,
    config_path : String,
    job_flag : String?,
    parallel : Bool,
    dry_run : Bool
  )
    config = Config.new(
      repo_token: repo_token,
      job_flag: job_flag,
      path: config_path,
    )
    source_files = Parser.new(coverage_file).parse
    api = Api::Jobs.new(config, parallel, source_files, Git.info)

    api.send_request(dry_run)
  end

  def parallel_done(repo_token : String?, config_path : String, dry_run : Bool)
    config = Config.new(repo_token: repo_token, path: config_path)
    api = Api::Webhook.new(config)

    api.send_request(dry_run)
  end
end
