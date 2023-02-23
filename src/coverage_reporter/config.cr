require "./yaml_config"
require "./base_exception"
require "./ci/*"

module CoverageReporter
  class Config
    getter repo_token : String?
    getter flag_name : String?

    @options : Hash(Symbol, String)?

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
      CI::Local,
    }

    def initialize(
      repo_token : String?,
      path : String = "",
      @flag_name : String? = nil
    )
      @yaml = YamlConfig.new(path)

      @repo_token =
        repo_token.presence ||
          ENV["COVERALLS_REPO_TOKEN"]?.presence ||
          @yaml["repo_token"]?.try(&.to_s).presence ||
          @yaml["repo_secret_token"]?.try(&.to_s).presence

      raise MissingTokenException.new if !@repo_token
    end

    delegate :[], to: to_h
    delegate :[]?, to: to_h

    def to_h
      @options ||= CI::Generic.options.merge(ci_options).merge(custom_options).merge({
        :repo_token => repo_token,
        :flag_name  => flag_name,
      }.compact)
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
        service_name: ENV["COVERALLS_SERVICE_NAME"]?.presence || @yaml["service_name"]?.try(&.to_s).presence,
        service_number: ENV["COVERALLS_SERVICE_NUMBER"]?.presence,
        service_job_id: ENV["COVERALLS_SERVICE_JOB_ID"]?.presence,
        service_job_number: ENV["COVERALLS_SERVICE_JOB_NUMBER"]?.presence,
        service_branch: ENV["COVERALLS_GIT_BRANCH"]?.presence,
        commit_sha: ENV["COVERALLS_GIT_COMMIT"]?.presence,
        repo_name: ENV["COVERALLS_REPO_NAME"]?.presence || @yaml["repo_name"]?.try(&.to_s).presence,
      ).to_h
    end
  end
end
