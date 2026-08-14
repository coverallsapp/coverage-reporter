require "./yaml_config"
require "./base_exception"
require "./ci/*"

module CoverageReporter
  class Config
    getter repo_token : String?
    getter flag_name : String?

    @options : Hash(Symbol, String)?
    @yaml : YamlConfig

    class MissingTokenException < BaseException
      def message
        "🚨 Missing Repo Token. Set using `-r <token>` or `COVERALLS_REPO_TOKEN=<token>`"
      end
    end

    CI_OPTIONS = {
      CI::CircleCI,
      CI::Github,
      CI::Gitlab,
      CI::Travis,
      CI::Semaphore,
      CI::Jenkins,
      CI::Appveyor,
      CI::Tddium,
      CI::Azure,
      CI::Buildkite,
      CI::Codefresh,
      CI::Codeship,
      CI::Surf,
      CI::Wercker,
      CI::Drone,
      CI::XcodeCloud,
      CI::Rwx,
      CI::Local,
    }

    DEFAULT_ENDPOINT = "https://coveralls.io"
    LOCAL_ENDPOINT   = "http://localhost:3000"

    def initialize(
      repo_token : String?,
      path : String? = "",
      @flag_name : String? = nil,
      @overrides : CI::Options? = nil,
      @compare_ref : String? = nil,
      @compare_sha : String? = nil,
    )
      @yaml = YamlConfig.read(path)

      @repo_token =
        repo_token.presence ||
          ENV["COVERALLS_REPO_TOKEN"]?.presence ||
          @yaml.repo_token.presence ||
          @yaml.repo_secret_token.presence

      raise MissingTokenException.new if !@repo_token
    end

    delegate :[], to: to_h
    delegate :[]?, to: to_h
    delegate :carryforward, to: @yaml

    def to_h
      @options ||=
        CI::Generic.options
          .merge(ci_options)
          .merge(custom_options)
          .merge(@overrides.try(&.to_h) || {} of Symbol => String)
          .merge({
            :repo_token  => repo_token,
            :flag_name   => flag_name,
            :compare_ref => @compare_ref,
            :compare_sha => @compare_sha,
          }.compact)
    end

    def endpoint
      if ENV["COVERALLS_ENDPOINT"]?.presence
        return ENV["COVERALLS_ENDPOINT"]
      end

      if ENV["COVERALLS_DEVELOPMENT"]?.presence
        return LOCAL_ENDPOINT
      end

      @yaml.endpoint.presence || DEFAULT_ENDPOINT
    end

    private def ci_options : Hash(Symbol, String)
      CI_OPTIONS.each do |ci|
        res = ci.options
        return res if res
      end

      {} of Symbol => String
    end

    private def custom_options : Hash(Symbol, String)
      CI::Options.new(
        service_name: ENV["COVERALLS_SERVICE_NAME"]?.presence || @yaml.service_name.presence,
        service_number: ENV["COVERALLS_SERVICE_NUMBER"]?.presence,
        service_job_id: ENV["COVERALLS_SERVICE_JOB_ID"]?.presence,
        service_job_number: ENV["COVERALLS_SERVICE_JOB_NUMBER"]?.presence,
        service_branch: ENV["COVERALLS_GIT_BRANCH"]?.presence,
        service_pull_request: ENV["COVERALLS_PULL_REQUEST"]?.presence,
        service_event_type: ENV["COVERALLS_EVENT_TYPE"]?.presence,
        commit_sha: ENV["COVERALLS_GIT_COMMIT"]?.presence,
        repo_name: ENV["COVERALLS_REPO_NAME"]?.presence || @yaml.repo_name.presence,
      ).to_h
    end
  end
end
