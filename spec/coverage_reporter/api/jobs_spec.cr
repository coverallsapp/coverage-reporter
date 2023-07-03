require "../../spec_helper"
require "http"

Spectator.describe CoverageReporter::Api::Jobs do
  subject { described_class.new(config, parallel, source_files, git_info) }

  let(config) { CoverageReporter::Config.new("token") }
  let(parallel) { true }
  let(git_info) { {:branch => "chore/add-tests", :head => {:message => "add tests"}} }
  let(source_files) do
    CoverageReporter::SourceFiles.new(
      [
        CoverageReporter::FileReport.new(
          name: "app/main.cr",
          coverage: [1, 2, nil] of UInt64?,
          format: "cobertura",
        ),
        CoverageReporter::FileReport.new(
          name: "app/helper.cr",
          coverage: [5, nil, 43] of UInt64?,
          format: "cobertura",
        ),
      ],
      "cobertura.xml",
    )
  end

  let(endpoint) { "#{CoverageReporter::Config::DEFAULT_ENDPOINT}/api/#{CoverageReporter::Api::Jobs::API_VERSION}/jobs" }
  let(boundary) { CoverageReporter::Api::Jobs::BOUNDARY }
  let(headers) do
    {
      "Content-Type"                 => "multipart/form-data; boundary=#{boundary}",
      "X-Coveralls-Reporter"         => "coverage-reporter",
      "X-Coveralls-Reporter-Version" => CoverageReporter::VERSION,
      "X-Coveralls-Coverage-Formats" => "cobertura",
      "X-Coveralls-Source"           => "cli",
    }
  end
  let(request_body) do
    data = config.to_h.merge({
      :source_files => [
        {
          :name     => "app/main.cr",
          :coverage => [1, 2, nil],
        },
        {
          :name     => "app/helper.cr",
          :coverage => [5, nil, 43],
        },
      ],
      :parallel => parallel,
      :git      => git_info,
      :run_at   => ENV["COVERALLS_RUN_AT"],
    }).to_json.to_s

    json_file = IO::Memory.new(
      String.build do |io|
        Compress::Gzip::Writer.open(io, &.print(data))
      end
    )

    body = IO::Memory.new
    HTTP::FormData.build(body, boundary) do |formdata|
      metadata = HTTP::FormData::FileMetadata.new(filename: "json_file")
      headers = HTTP::Headers{"Content-Type" => "application/gzip"}
      formdata.file("json_file", json_file, metadata, headers)
    end

    body.to_s
  end

  before_each do
    ENV["COVERALLS_RUN_AT"] = Time::Format::RFC_3339.format(Time.local)
  end

  after_each do
    WebMock.reset
    ENV.clear
  end

  it "calls the /jobs endpoint" do
    WebMock.stub(:post, endpoint).with(
      headers: headers,
      body: request_body,
    ).to_return(status: 200, body: {:result => "ok"}.to_json)

    subject.send_request
  end

  it "raises error when 500 is received" do
    WebMock.stub(:post, endpoint).with(
      headers: headers,
      body: request_body,
    ).to_return(status: 500, body: {:result => "Internal Server Error"}.to_json)

    expect { subject.send_request }.to raise_error(CoverageReporter::Api::InternalServerError)
  end

  it "raises error when 422 is received" do
    WebMock.stub(:post, endpoint).with(
      headers: headers,
      body: request_body,
    ).to_return(status: 422, body: {:result => "Unprocessable Entity"}.to_json)

    expect { subject.send_request }.to raise_error(CoverageReporter::Api::UnprocessableEntity)
  end

  it "redirects" do
    redirect_url = "https://coveralls-redirect.io/api/v1/jobs"

    WebMock.stub(:post, endpoint).with(
      headers: headers,
      body: request_body,
    ).to_return(status: 307, body: "Temporary redirect", headers: {"location" => redirect_url})

    WebMock.stub(:post, redirect_url).with(
      headers: headers,
      body: request_body,
    ).to_return(status: 200, body: {:result => "ok"}.to_json)

    expect { subject.send_request }.not_to raise_error
  end

  it "redirects relatively" do
    redirect_path = "/api/v9/jobs"
    redirect_url = "#{CoverageReporter::Config::DEFAULT_ENDPOINT}#{redirect_path}"

    WebMock.stub(:post, endpoint).with(
      headers: headers,
      body: request_body,
    ).to_return(status: 302, body: "Found", headers: {"location" => redirect_path})

    WebMock.stub(:post, redirect_url).with(
      headers: headers,
      body: request_body,
    ).to_return(status: 200, body: {:result => "ok"}.to_json)

    expect { subject.send_request }.not_to raise_error
  end
end
