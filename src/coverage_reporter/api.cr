require "crest"
require "json"
require "./config.cr"

module CoverageReporter
  class Api
    API_VERSION = "v1"

    class Poster < Api
      def initialize(
          token : String,
          @yaml : YamlConfig,
          @git : Hash(Symbol, String | Hash(Symbol, String)),
          @job_flag : String,
          parallel : Bool,
          source_files : Array(Hash(Symbol, Array(Int32 | Nil) | String))
      )
        @parallel = parallel || (ENV["COVERALLS_PARALLEL"]? && ENV["COVERALLS_PARALLEL"] != "false")
        puts "⭐️ Running in parallel mode. You must call the webhook after all jobs finish: `coveralls --done`" unless CoverageReporter.quiet?
        @sauce = source_files || {} of String => Array(Int32)

        @general_config = Config.new(token, @job_flag, @yaml)
      end

      def send_request
        data = build_request
        api_url = uri("api/#{API_VERSION}/jobs")

        unless quiet?
          puts "  ·job_flag: #{@job_flag}" if @job_flag != ""
          puts "  ·parallel: true" if @parallel

          puts "🚀 Posting coverage data to #{api_url}"
        end

        res = Crest.post(
          api_url,
          headers: { "Content-Type" => "application/json" },
          form: { :json => data.to_json.to_s }.to_json
        )

        show_response(res)
        true
      end

      private def build_request
        @general_config.get_config.merge(
          {
            :source_files => @sauce,
            :git => @git,
            :parallel => @parallel,
          }
        )
      end
    end

    class Webhook < Api
      @token : String | Nil
      @build_num : String | Nil

      def initialize(token : String, yaml : YamlConfig)
        config = Config.new(token, nil, yaml).get_config

        @token = config[:repo_token]
        @build_num = config[:service_number]
      end

    def send_request
        webhook_url = uri("webhook")

        unless quiet?
          puts "⭐️ Calling parallel done webhook: #{webhook_url}"
        end

        data = {
          :repo_token => @token,
          :payload => { 
            :build_num => @build_num, 
            :status => "done" 
          }
        }

        res = Crest.post(
          webhook_url,
          headers: { "Content-Type" => "application/json" },
          form: data.to_json
        )

        show_response(res)
        true
      end
    end

    private def show_response(res)
      return if quiet?
      # TODO: include info about account status
      puts "---\n✅ API Response: #{res.body}\n- 💛, Coveralls"
    end

    private def uri(path)
      if ENV["COVERALLS_ENDPOINT"]?
        host = ENV["COVERALLS_ENDPOINT"]?
        domain = ENV["COVERALLS_ENDPOINT"]?
      else
        host = ENV["COVERALLS_DEVELOPMENT"]? ? "localhost:3000" : "coveralls.io"
        protocol = ENV["COVERALLS_DEVELOPMENT"]? ? "http" : "https"
        domain = "#{protocol}://#{host}"
      end

      "#{domain}/#{path}"
    end

    private def quiet?
      CoverageReporter.quiet?
    end
  end
end
