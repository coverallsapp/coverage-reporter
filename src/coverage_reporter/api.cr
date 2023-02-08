require "./config.cr"
require "./api/*"

module CoverageReporter
  module Api
    API_VERSION = "v1"

    extend self

    def show_response(res)
      # TODO: include info about account status
      Log.info "---\n✅ API Response: #{res.body.to_pretty_json}\n- 💛, Coveralls"
    end

    def uri(path)
      if ENV["COVERALLS_ENDPOINT"]?
        host = ENV["COVERALLS_ENDPOINT"]?
        domain = ENV["COVERALLS_ENDPOINT"]?
      else
        host = ENV["COVERALLS_DEVELOPMENT"]? ? "localhost:3000" : "coveralls.io"
        protocol = ENV["COVERALLS_DEVELOPMENT"]? ? "http" : "https"
        domain = "#{protocol}://#{host}"
      end

      "#{domain}/#{path}"
    end
  end
end
