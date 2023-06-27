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

  before_each do
    ENV["COVERALLS_RUN_AT"] = Time::Format::RFC_3339.format(Time.local)
  end

  after_each do
    WebMock.reset
    ENV.clear
  end

  it "calls the /jobs endpoint" do
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

    req_body = IO::Memory.new
    boundary = CoverageReporter::Api::Jobs::BOUNDARY
    HTTP::FormData.build(req_body, boundary) do |formdata|
      metadata = HTTP::FormData::FileMetadata.new(filename: "json_file")
      headers = HTTP::Headers{"Content-Type" => "application/gzip"}
      formdata.file("json_file", json_file, metadata, headers)
    end

    WebMock.stub(:post, endpoint).with(
      headers: {
        "Content-Type"                 => "multipart/form-data; boundary=#{boundary}",
        "X-Coveralls-Reporter"         => "coverage-reporter",
        "X-Coveralls-Reporter-Version" => CoverageReporter::VERSION,
        "X-Coveralls-Coverage-Formats" => "cobertura",
        "X-Coveralls-Source"           => "cli",
      },
      body: req_body.to_s,
    ).to_return(status: 200, body: {:result => "ok"}.to_json)

    subject.send_request
  end
end
