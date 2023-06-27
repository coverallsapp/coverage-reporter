require "./config"
require "./api/*"
require "http"

module CoverageReporter
  module Api
    extend self

    class HTTPError < Exception
      getter status_code : Int32
      getter response : String

      def initialize(response : HTTP::Client::Response)
        super(response.status_message)
        @status_code = response.status_code
        @response = response.body
      end
    end

    class InternalServerError < HTTPError; end

    class UnprocessableEntity < HTTPError; end

    DEFAULT_HEADERS = HTTP::Headers{
      "X-Coveralls-Reporter"         => "coverage-reporter",
      "X-Coveralls-Reporter-Version" => VERSION,
      "X-Coveralls-Source"           => ENV["COVERALLS_SOURCE_HEADER"]?.presence || "cli",
      "Accept"                       => "*/*",
      "User-Agent"                   => "Crystal #{Crystal::VERSION}",
    }

    def handle_response(res)
      case res.status
      when HTTP::Status::OK, HTTP::Status::CREATED
        Log.info "---\n✅ API Response: #{res.body}\n- 💛, Coveralls"
      when HTTP::Status::INTERNAL_SERVER_ERROR
        raise InternalServerError.new(res)
      when HTTP::Status::UNPROCESSABLE_ENTITY
        raise UnprocessableEntity.new(res)
      else
        raise HTTPError.new(res)
      end
    end
  end
end
