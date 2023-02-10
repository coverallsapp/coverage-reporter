require "./yaml_config"
require "./base_exception"
require "./ci/*"

module CoverageReporter
  class Config
    @options : Hash(Symbol, String)?
    @repo_token : String?

    class MissingTokenException < BaseException
      def message
        "🚨 Missing Repo Token. Set using `-r <token>` or `COVERALLS_REPO_TOKEN=<token>`"
      end
    end

    CI_OPTIONS = {
      CI::CircleCI,
      CI::Github,
      CI::Gitlab,
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

    delegate :[], to: to_h
    delegate :[]?, to: to_h

    def to_h
      @options ||=
        begin
          options = {
            :repo_token   => @repo_token,
            :job_flat     => @job_flag,
            :flag_name    => ENV["COVERALLS_FLAG_NAME"]?,
            :service_name => ENV["COVERALLS_SERVICE_NAME"]?,
          }.compact

          options.merge!(ci_options)

          CI::Generic.options.merge(options)
        end
    end

    private def ci_options : Hash(Symbol, String)
      # FIXME: Does CI::Travis really need a *service_name* argument?
      #   Why other CIs don't need it?
      travis = CI::Travis.options(@yaml["service_name"]?.try(&.to_s))
      return travis if travis

      CI_OPTIONS.each do |ci|
        res = ci.options
        return res if res
      end

      {} of Symbol => String
    end
  end
end
