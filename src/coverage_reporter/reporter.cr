require "./*"

module CoverageReporter
  class Reporter
    getter coverage_file,
      base_path,
      repo_token,
      config_path,
      job_flag_name,
      carryforward,
      overrides,
      parallel,
      dry_run

    class NoSourceFiles < BaseException
      def message
        "🚨 Nothing to report"
      end
    end

    def initialize(
      @coverage_file : String?,
      @base_path : String?,
      @repo_token : String?,
      @config_path : String?,
      @job_flag_name : String?,
      @carryforward : String?,
      @overrides : CI::Options?,
      @parallel : Bool,
      @dry_run : Bool
    )
    end

    # Parses the coverage reports in the current directory or the given *coverage_file*
    # and sends the report to Coveralls API.
    #
    # If *coverage_file* is provided only its content will be parsed. Otherwise
    # current directory will be searched for all supported report formats.
    def report
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
    def parallel_done
      api = Api::Webhook.new(config, carryforward)

      api.send_request(dry_run)
    end

    private def config
      @config ||= Config.new(
        repo_token: repo_token,
        flag_name: job_flag_name,
        path: config_path,
        overrides: overrides,
      )
    end
  end
end
