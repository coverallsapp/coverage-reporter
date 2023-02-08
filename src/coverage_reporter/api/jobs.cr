require "../file_report"
require "crest"
require "json"

module CoverageReporter
  module Api
    class Jobs
      @source : Array(Hash(Symbol, String | Array(Int32?)))

      def initialize(
        token : String?,
        @yaml : YamlConfig,
        @git : Hash(Symbol, String | Hash(Symbol, String)),
        @job_flag : String?,
        parallel : Bool,
        source_files : Array(FileReport)
      )
        @parallel = parallel || (ENV["COVERALLS_PARALLEL"]? && ENV["COVERALLS_PARALLEL"] != "false")

        if @parallel
          Log.info "⭐️ Running in parallel mode." \
                   "You must call the webhook after all jobs finish: `coveralls --done`"
        end

        @source = source_files.map &.to_h

        @general_config = Config.new(token, @job_flag, @yaml)
      end

      def send_request
        data = build_request
        api_url = Api.uri("api/#{API_VERSION}/jobs")

        Log.info "  ·job_flag: #{@job_flag}" if @job_flag != ""
        Log.info "  ·parallel: true" if @parallel
        Log.info "🚀 Posting coverage data to #{api_url}"

        Log.debug "---\n⛑ Debug Output:\n#{data.to_pretty_json}"

        res = Crest.post(
          api_url,
          headers: {"Content-Type" => "application/json"},
          form: {:json => data.to_json.to_s}.to_json,
          tls: ENV["COVERALLS_ENDPOINT"]? ? OpenSSL::SSL::Context::Client.insecure : nil
        )

        Api.show_response(res)
        true
      end

      private def build_request
        @general_config.get_config.merge(
          {
            :source_files => @source,
            :git          => @git,
            :parallel     => @parallel,
          }
        )
      end
    end
  end
end
