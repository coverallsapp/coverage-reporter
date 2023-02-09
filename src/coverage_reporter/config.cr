require "./yaml_config"
require "./base_exception"
require "./ci/*"

module CoverageReporter
  class Config
    @params : Hash(Symbol, String)?
    @repo_token : String?

    DEFAULT_LOCATION = ".coveralls.yml"

    class MissingTokenException < BaseException
      def message
        "🚨 Missing Repo Token. Set using `-r <token>` or `COVERALLS_REPO_TOKEN=<token>`"
      end
    end

    def initialize(
      repo_token : String?,
      path : String,
      @job_flag : String? = nil
    )
      @yaml = YamlConfig.new(path)

      @repo_token =
        repo_token.presence ||
          ENV["COVERALLS_REPO_TOKEN"]?.presence ||
          @yaml["repo_token"]?.try(&.to_s).presence ||
          @yaml["repo_secret_token"]?.try(&.to_s).presence

      raise MissingTokenException.new if !@repo_token
    end

    delegate :[], to: params
    delegate :[]?, to: params

    def to_h
      params
    end

    private def params
      @params ||=
        begin
          params = {
            :repo_token   => @repo_token,
            :job_flat     => @job_flag,
            :flag_name    => ENV["COVERALLS_FLAG_NAME"]?,
            :service_name => ENV["COVERALLS_SERVICE_NAME"]?,
          }.compact

          params.merge!(ci_params)

          CI::Generic.params.merge(params)
        end
    end

    private def ci_params : Hash(Symbol, String)
      CI::Travis.params(@yaml["service_name"]?.try(&.to_s)) ||
        CI::CircleCI.params ||
        CI::Semaphore.params ||
        CI::Jenkins.params ||
        CI::Appveyor.params ||
        CI::Tddium.params ||
        CI::Gitlab.params ||
        CI::Local.params ||
        {} of Symbol => String
    end
  end
end
