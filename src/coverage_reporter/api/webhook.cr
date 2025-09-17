require "http"
require "json"

module CoverageReporter
  class Api::Webhook
    def initialize(
      @config : Config,
      @carryforward : String?,
      @git : Hash(Symbol, Hash(Symbol, String) | String)
    )
    end

    def send_request(dry_run : Bool = false)
      if ENV["DEBUG_WEBHOOK"]?
        puts ">>> [Webhook] Sending request to: #{endpoint}/webhook"
      end

      webhook_url = "#{@config.endpoint}/webhook"
      webhook_uri = URI.parse(webhook_url)

      Log.info "⭐️ Calling parallel done webhook: #{webhook_url}"

      data = @config.to_h.merge({
        :carryforward => @carryforward,
        :payload      => {
          :build_num => @config[:service_number]?,
          :status    => "done",
        },
        :git => @git,
      }.compact)

      Log.debug "---\n⛑ Debug Output:\n#{data.to_pretty_json}"

      return if dry_run
      headers = DEFAULT_HEADERS.dup
      headers.merge!(HTTP::Headers{
        "Content-Type"   => "application/json",
        "X-Coveralls-CI" => @config[:service_name]? || "unknown",
      })

      res = Api.with_redirects(webhook_uri) do |uri|
        HTTP::Client.post(
          uri,
          headers: headers,
          body: data.to_json,
          tls: Api.tls_for(uri)
        )
      end

      Api.handle_response(res)
    end
  end
end
