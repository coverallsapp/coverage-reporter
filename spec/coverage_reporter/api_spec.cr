require "../spec_helper"

Spectator.describe CoverageReporter::Api::HTTPError do
  # Builds a response the way `Api.handle_response` would see it, so the error
  # under test is constructed exactly as it is in production.
  def build_error(headers : HTTP::Headers, status : Int32 = 500, body : String = "boom")
    response = HTTP::Client::Response.new(status, body: body, headers: headers)
    CoverageReporter::Api::HTTPError.new(response)
  end

  describe "#trace_id" do
    it "returns nil when the response carries no tracing header" do
      error = build_error(HTTP::Headers{"Content-Type" => "text/plain"})

      expect(error.trace_id).to be_nil
    end

    it "returns nil when the response has no headers at all" do
      error = build_error(HTTP::Headers.new)

      expect(error.trace_id).to be_nil
    end

    # Each header the probe knows about, so reordering the chain can't silently
    # drop one.
    sample [
      "cf-ray",
      "x-request-id",
      "x-amzn-requestid",
      "x-amzn-trace-id",
      "x-trace-id",
    ] do |header|
      it "picks up the #{header} header" do
        error = build_error(HTTP::Headers{header => "trace-abc-123"})

        expect(error.trace_id).to eq("trace-abc-123")
      end
    end

    it "matches the header case-insensitively" do
      error = build_error(HTTP::Headers{"CF-RAY" => "trace-abc-123"})

      expect(error.trace_id).to eq("trace-abc-123")
    end

    it "prefers cf-ray when several tracing headers are present" do
      error = build_error(HTTP::Headers{
        "cf-ray"       => "from-cloudflare",
        "x-request-id" => "from-origin",
      })

      expect(error.trace_id).to eq("from-cloudflare")
    end

    it "falls through to the next header when the preferred one is absent" do
      error = build_error(HTTP::Headers{
        "x-amzn-requestid" => "from-amazon",
        "x-trace-id"       => "from-generic",
      })

      expect(error.trace_id).to eq("from-amazon")
    end
  end

  describe "#headers" do
    it "exposes the response headers" do
      error = build_error(HTTP::Headers{"cf-ray" => "trace-abc-123"})

      expect(error.headers["cf-ray"]).to eq("trace-abc-123")
    end
  end

  # The subclasses are what the CLI actually rescues, so they need the behaviour
  # too.
  describe "subclasses" do
    it "InternalServerError exposes the trace id" do
      response = HTTP::Client::Response.new(
        500, body: "boom", headers: HTTP::Headers{"cf-ray" => "trace-500"}
      )
      error = CoverageReporter::Api::InternalServerError.new(response)

      expect(error.trace_id).to eq("trace-500")
    end

    it "UnprocessableEntity exposes the trace id" do
      response = HTTP::Client::Response.new(
        422, body: "nope", headers: HTTP::Headers{"cf-ray" => "trace-422"}
      )
      error = CoverageReporter::Api::UnprocessableEntity.new(response)

      expect(error.trace_id).to eq("trace-422")
    end
  end
end
