require "../source_files"
require "../git"
require "../config"
require "http"
require "compress/gzip"
require "json"

module CoverageReporter
  class Api::Jobs
    API_VERSION = "v1"
    BOUNDARY    = "CoverageReporterBoundary".rjust(50, '-')

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

      headers = DEFAULT_HEADERS.dup
      headers.merge!(HTTP::Headers{
        "X-Coveralls-Coverage-Formats" => @source_files.map(&.format.to_s).sort!.uniq!.join(","),
        "X-Coveralls-CI"               => @config[:service_name]? || "unknown",
      })

      Log.info "  ·job_flag: #{@config.flag_name}" if @config.flag_name
      Log.info "🚀 Posting coverage data to #{api_url}"

      Log.debug "---\n⛑ Debug Headers:\n#{headers.to_pretty_json}"
      Log.debug "---\n⛑ Debug Output:\n#{data.to_pretty_json}"

      return if dry_run

      gzipped_json = String.build do |io|
        Compress::Gzip::Writer.open(io, &.print(data.to_json.to_s))
      end

      with_file(IO::Memory.new(gzipped_json)) do |content_type, body|
        # NOTE: Removing quotes from boundary -- required by Coveralls.io nginx rule
        headers.merge!(HTTP::Headers{"Content-Type" => content_type.gsub("\"", "")})

        response = HTTP::Client.post(
          api_url,
          body: body,
          headers: headers,
          tls: ENV["COVERALLS_ENDPOINT"]? ? OpenSSL::SSL::Context::Client.insecure : nil
        )

        Api.handle_response(response)
      end
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

    private def with_file(gzfile, &)
      IO.pipe do |reader, writer|
        channel = Channel(String).new(1)

        spawn do
          HTTP::FormData.build(writer, BOUNDARY) do |formdata|
            channel.send(formdata.content_type)

            metadata = HTTP::FormData::FileMetadata.new(filename: "json_file")
            headers = HTTP::Headers{"Content-Type" => "application/gzip"}
            formdata.file("json_file", gzfile, metadata, headers)
          end

          writer.close
        end

        yield(channel.receive, reader)
      end
    end
  end
end
