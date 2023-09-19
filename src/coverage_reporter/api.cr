require "./config"
require "./api/*"
require "http"

module CoverageReporter
  module Api
    extend self

    DEFAULT_HEADERS = HTTP::Headers{
      "X-Coveralls-Reporter"         => "coverage-reporter",
      "X-Coveralls-Reporter-Version" => VERSION,
      "X-Coveralls-Source"           => ENV["COVERALLS_SOURCE_HEADER"]?.presence || "cli",
      "Accept"                       => "*/*",
      "User-Agent"                   => "Crystal #{Crystal::VERSION}",
    }

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

    def tls_for(uri : URI, force_insecure_requests : Bool = false) : OpenSSL::SSL::Context::Client?
      return OpenSSL::SSL::Context::Client.insecure if force_insecure_requests
      return nil unless uri.scheme == "https"
      return nil if uri.host == "coveralls.io"

      OpenSSL::SSL::Context::Client.insecure
    end

    def with_ssl_errors_handling() : HTTP::Client::Response
      begin
        yield
      rescue ex : OpenSSL::SSL::Error
        if OpenSSLVersion.new.can_fail?
          Log.error <<-ERROR
            Consider upgrading `openssl` library to version >= #{OpenSSLVersion::WORKS} or using --force-insecure-requests flag
          ERROR
        end
        raise(ex)
      end
    end

    def with_redirects(uri : URI, max_redirects : Int32 = 10, & : URI -> HTTP::Client::Response) : HTTP::Client::Response
      redirect_num = 0
      response = yield(uri)

      while redirect?(response) && redirect_num < max_redirects
        new_uri = URI.parse(response.headers["location"])
        unless new_uri.absolute?
          new_uri.scheme = uri.scheme
          new_uri.host = uri.host
        end
        uri = new_uri
        response = yield(uri)
        redirect_num += 1
      end

      response
    end

    def redirect?(response : HTTP::Client::Response) : Bool
      {301, 302, 303, 307, 308}.includes?(response.status_code)
    end
  end
end
