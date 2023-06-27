require "http"
require "json"

module CoverageReporter
  class Api::Webhook
    def initialize(@config : Config, @carryforward : String?)
    end

    def send_request(dry_run : Bool = false)
      webhook_url = "#{@config.endpoint}/webhook"

      Log.info "⭐️ Calling parallel done webhook: #{webhook_url}"

      data = @config.to_h.merge({
        :carryforward => @carryforward,
        :payload      => {
          :build_num => @config[:service_number]?,
          :status    => "done",
        },
      }.compact)

      Log.debug "---\n⛑ Debug Output:\n#{data.to_pretty_json}"

      return if dry_run
      headers = DEFAULT_HEADERS.dup
      headers.merge!(HTTP::Headers{
        "Content-Type"   => "application/json",
        "X-Coveralls-CI" => @config[:service_name]? || "unknown",
      })

      res = HTTP::Client.post(
        webhook_url,
        headers: headers,
        body: data.to_json,
        tls: ENV["COVERALLS_ENDPOINT"]? ? OpenSSL::SSL::Context::Client.insecure : nil
      )

      Api.handle_response(res)
    end
  end
end
