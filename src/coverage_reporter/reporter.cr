require "./*"

module CoverageReporter
  class Reporter
    record Settings,
      base_path : String? = nil,
      carryforward : String? = nil,
      compare_ref : String? = nil,
      compare_sha : String? = nil,
      config_path : String? = nil,
      coverage_files : Array(String) | Nil = nil,
      coverage_format : String? = nil,
      dry_run : Bool = false,
      fail_empty : Bool = false,
      job_flag_name : String? = nil,
      overrides : CI::Options? = nil,
      parallel : Bool = false,
      repo_token : String? = nil

    class NoSourceFiles < BaseException
      def message
        "🚨 Nothing to report"
      end
    end

    getter settings : Settings

    def initialize(*args, **kwargs)
      @settings = Settings.new(*args, **kwargs)
    end

    def configure(*args, **kwargs)
      initialize(*args, **kwargs)
    end

    # Parses the coverage reports in the current directory or the given *coverage_file*
    # and sends the report to Coveralls API.
    #
    # If *coverage_file* is provided only its content will be parsed. Otherwise
    # current directory will be searched for all supported report formats.
    def report
      source_files = Parser.new(
        coverage_files: settings.coverage_files,
        coverage_format: settings.coverage_format,
        base_path: settings.base_path,
      ).parse
      raise NoSourceFiles.new(settings.fail_empty) unless source_files.size > 0

      api = Api::Jobs.new(config, settings.parallel, source_files, Git.info(config))

      api.send_request(settings.dry_run)
    end

    # Reports that all parallel jobs were reported and Coveralls can aggregate
    # coverage results.
    #
    # Refers to a build via `service_number` parameter which is either taken
    # from a CI-specific ENV, or can be set explicitly via `COVERALLS_SERVICE_NUMBER`
    # environment variable.
    def parallel_done
      api = Api::Webhook.new(config, settings.carryforward || config.carryforward)

      api.send_request(settings.dry_run)
    end

    private def config
      @config ||= Config.new(
        repo_token: settings.dry_run ? "dry-run" : settings.repo_token,
        flag_name: settings.job_flag_name,
        compare_ref: settings.compare_ref,
        compare_sha: settings.compare_sha,
        path: settings.config_path,
        overrides: settings.overrides,
      )
    end
  end
end
