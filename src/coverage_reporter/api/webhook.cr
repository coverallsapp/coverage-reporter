require "crest"
require "json"

module CoverageReporter
  class Api::Webhook
    def initialize(@config : Config)
    end

    def send_request(dry_run : Bool = false)
      webhook_url = Api.uri("webhook")

      Log.info "⭐️ Calling parallel done webhook: #{webhook_url}"

      data = @config.to_h.merge({
        :payload => {
          :build_num => @config[:service_number]?,
          :status    => "done",
        },
      })

      Log.debug "---\n⛑ Debug Output:\n#{data.to_pretty_json}"

      return if dry_run

      res = Crest.post(
        webhook_url,
        headers: {"Content-Type" => "application/json"},
        form: data.to_json,
        tls: ENV["COVERALLS_ENDPOINT"]? ? OpenSSL::SSL::Context::Client.insecure : nil
      )

      Api.show_response(res)
    end
  end
end
