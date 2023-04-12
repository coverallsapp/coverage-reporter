require "./config"
require "./api/*"

module CoverageReporter
  module Api
    extend self

    DEFAULT_HEADERS = {
      "X-Coveralls-Reporter"         => "coverage-reporter",
      "X-Coveralls-Reporter-Version" => VERSION,
      "X-Coveralls-Source"           => ENV["COVERALLS_SOURCE_HEADER"]?.presence || "cli",
    }

    def show_response(res)
      # TODO: include info about account status
      Log.info "---\n✅ API Response: #{res.body}\n- 💛, Coveralls"
    end
  end
end
