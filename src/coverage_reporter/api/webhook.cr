require "crest"
require "json"

module CoverageReporter
  module Api
    class Webhook
      @token : String | Nil
      @build_num : String | Nil

      def initialize(config : Config)
        @token = config[:repo_token]?
        @build_num = config[:service_number]?
      end

      def send_request
        webhook_url = Api.uri("webhook")

        Log.info "⭐️ Calling parallel done webhook: #{webhook_url}"

        data = {
          :repo_token => @token,
          :payload    => {
            :build_num => @build_num,
            :status    => "done",
          },
        }

        Log.debug "---\n⛑ Debug Output:\n#{data.to_pretty_json}"

        res = Crest.post(
          webhook_url,
          headers: {"Content-Type" => "application/json"},
          form: data.to_json,
          tls: ENV["COVERALLS_ENDPOINT"]? ? OpenSSL::SSL::Context::Client.insecure : nil
        )

        Api.show_response(res)
        true
      end
    end
  end
end
