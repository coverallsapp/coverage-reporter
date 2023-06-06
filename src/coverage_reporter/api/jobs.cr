require "../source_files"
require "../git"
require "../config"
require "crest"
require "json"

module CoverageReporter
  class Api::Jobs
    API_VERSION = "v1"

    def initialize(
      @config : Config,
      @parallel : Bool,
      @source_files : SourceFiles,
      @git_info : Hash(Symbol, Hash(Symbol, String) | String)
    )
      service_number = @config.to_h[:service_number]?
      if @parallel
        Log.info(
          String.build do |io|
            io << "⭐️ Running in parallel mode. "
            if service_number
              io << "You must call the webhook after all jobs finish: `coveralls done --build-number #{service_number}`"
            end
          end
        )
        unless service_number
          Log.warn("⚠️ You won't be able to close the build because build number is empty.\n" \
                   "⚠️ Provide --build-number option or COVERALLS_SERVICE_NUMBER environment variable to " \
                   "create parallel jobs for one build and be able to close it.")
        end
      end
    end

    def send_request(dry_run : Bool = false)
      data = build_request
      api_url = "#{@config.endpoint}/api/#{API_VERSION}/jobs"

      headers = DEFAULT_HEADERS.merge({
        "Content-Type"                 => "application/json",
        "X-Coveralls-Coverage-Formats" => @source_files.map(&.format.to_s).sort!.uniq!.join(","),
        "X-Coveralls-CI"               => @config[:service_name]?,
      }.compact)

      Log.info "  ·job_flag: #{@config.flag_name}" if @config.flag_name
      Log.info "🚀 Posting coverage data to #{api_url}"

      Log.debug "---\n⛑ Debug Headers:\n#{headers.to_pretty_json}"
      Log.debug "---\n⛑ Debug Output:\n#{data.to_pretty_json}"

      return if dry_run

      res = Crest.post(
        api_url,
        headers: headers,
        form: {:json => data.to_json.to_s}.to_json,
        tls: ENV["COVERALLS_ENDPOINT"]? ? OpenSSL::SSL::Context::Client.insecure : nil
      )

      Api.show_response(res)
    end

    private def build_request
      @config.to_h.merge(
        {
          :source_files => @source_files.map(&.to_h),
          :parallel     => @parallel,
          :git          => @git_info,
          :run_at       => ENV.fetch("COVERALLS_RUN_AT", Time::Format::RFC_3339.format(Time.local)),
        }
      )
    end
  end
end
