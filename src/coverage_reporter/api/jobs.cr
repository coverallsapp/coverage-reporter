require "../file_report"
require "../git"
require "../config"
require "crest"
require "json"

module CoverageReporter
  module Api
    class Jobs
      @source : Array(Hash(Symbol, String | Array(Int32?)))
      @job_flag : String?

      def initialize(
        @config : Config,
        @parallel : Bool,
        source_files : Array(FileReport),
        @git_info : Hash(Symbol, Hash(Symbol, String) | String)
      )
        if @parallel
          Log.info "⭐️ Running in parallel mode." \
                   "You must call the webhook after all jobs finish: `coveralls --done`"
        end

        @source = source_files.map &.to_h
        @job_flag = @config[:job_flag]?
      end

      def send_request(dry_run : Bool = false)
        data = build_request
        api_url = Api.uri("api/#{API_VERSION}/jobs")

        Log.info "  ·job_flag: #{@job_flag}" if @job_flag
        Log.info "  ·parallel: true" if @parallel
        Log.info "🚀 Posting coverage data to #{api_url}"

        Log.debug "---\n⛑ Debug Output:\n#{data.to_pretty_json}"

        return if dry_run

        res = Crest.post(
          api_url,
          headers: {"Content-Type" => "application/json"},
          form: {:json => data.to_json.to_s}.to_json,
          tls: ENV["COVERALLS_ENDPOINT"]? ? OpenSSL::SSL::Context::Client.insecure : nil
        )

        Api.show_response(res)
      end

      private def build_request
        @config.to_h.merge(
          {
            :source_files => @source,
            :parallel     => @parallel,
            :git          => @git_info,
          }
        )
      end
    end
  end
end
