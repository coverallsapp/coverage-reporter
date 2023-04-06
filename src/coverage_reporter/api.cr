require "./config"
require "./api/*"

module CoverageReporter
  module Api
    extend self

    def show_response(res)
      # TODO: include info about account status
      Log.info "---\n✅ API Response: #{res.body}\n- 💛, Coveralls"
    end
  end
end
