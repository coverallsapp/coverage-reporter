require "./*"

module CoverageReporter
  class Reporter
    getter base_path,
      carryforward,
      compare_ref,
      compare_sha,
      config_path,
      coverage_file,
      coverage_format,
      dry_run,
      fail_empty,
      job_flag_name,
      overrides,
      parallel,
      repo_token

    class NoSourceFiles < BaseException
      def message
        "🚨 Nothing to report"
      end
    end

    def initialize(
      @base_path : String?,
      @carryforward : String?,
      @compare_ref : String?,
      @compare_sha : String?,
      @config_path : String?,
      @coverage_file : String?,
      @coverage_format : String?,
      @dry_run : Bool,
      @fail_empty : Bool,
      @job_flag_name : String?,
      @overrides : CI::Options?,
      @parallel : Bool,
      @repo_token : String?
    )
    end

    # Parses the coverage reports in the current directory or the given *coverage_file*
    # and sends the report to Coveralls API.
    #
    # If *coverage_file* is provided only its content will be parsed. Otherwise
    # current directory will be searched for all supported report formats.
    def report
      source_files = Parser.new(
        coverage_file: coverage_file,
        coverage_format: coverage_format,
        base_path: base_path,
      ).parse
      raise NoSourceFiles.new(fail_empty) unless source_files.size > 0

      api = Api::Jobs.new(config, parallel, source_files, Git.info(config))

      api.send_request(dry_run)
    end

    # Reports that all parallel jobs were reported and Coveralls can aggregate
    # coverage results.
    #
    # Refers to a build via `service_number` parameter which is either taken
    # from a CI-specific ENV, or can be set explicitly via `COVERALLS_SERVICE_NUMBER`
    # environment variable.
    def parallel_done
      api = Api::Webhook.new(config, carryforward)

      api.send_request(dry_run)
    end

    private def config
      @config ||= Config.new(
        repo_token: repo_token,
        flag_name: job_flag_name,
        compare_ref: compare_ref,
        compare_sha: compare_sha,
        path: config_path,
        overrides: overrides,
      )
    end
  end
end
