require "./coverage_reporter/*"

module CoverageReporter
  extend self

  VERSION = "0.2.7"

  class NoSourceFiles < BaseException
    def message
      "🚨 Nothing to report"
    end
  end

  # Parses the coverage reports in the current directory or the given *coverage_file*
  # and sends the report to Coveralls API.
  #
  # If *coverage_file* is provided only its content will be parsed. Otherwise
  # current directory will be searched for all supported report formats.
  def report(
    coverage_file : String?,
    base_path : String?,
    repo_token : String?,
    config_path : String,
    job_flag_name : String?,
    parallel : Bool,
    dry_run : Bool
  )
    config = Config.new(
      repo_token: repo_token,
      flag_name: job_flag_name,
      path: config_path,
    )
    source_files = Parser.new(coverage_file, base_path).parse
    raise NoSourceFiles.new unless source_files.size > 0

    api = Api::Jobs.new(config, parallel, source_files, Git.info(config))

    api.send_request(dry_run)
  end

  # Reports that all parallel jobs were reported and Coveralls can aggregate
  # coverage results.
  #
  # Refers to a build via `service_number` parameter which is either taken
  # from a CI-specific ENV, or can be set explicitly via `COVERALLS_SERVICE_NUMBER`
  # environment variable.
  def parallel_done(
    repo_token : String?,
    config_path : String,
    carryforward : String?,
    dry_run : Bool
  )
    config = Config.new(repo_token: repo_token, path: config_path)
    api = Api::Webhook.new(config, carryforward)

    api.send_request(dry_run)
  end
end
