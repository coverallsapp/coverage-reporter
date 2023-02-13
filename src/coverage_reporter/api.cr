require "./config"
require "./api/*"

module CoverageReporter
  module Api
    extend self

    API_VERSION    = "v1"
    DEFAULT_DOMAIN = "https://coveralls.io"
    LOCAL_DOMAIN   = "http://localhost:3000"

    def show_response(res)
      # TODO: include info about account status
      Log.info "---\n✅ API Response: #{res.body}\n- 💛, Coveralls"
    end

    def uri(path)
      if ENV["COVERALLS_ENDPOINT"]?.presence
        domain = ENV["COVERALLS_ENDPOINT"]
      else
        domain =
          if ENV["COVERALLS_DEVELOPMENT"]?.presence
            LOCAL_DOMAIN
          else
            DEFAULT_DOMAIN
          end
      end

      "#{domain}/#{path}"
    end
  end
end
