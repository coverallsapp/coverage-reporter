require "../../spec_helper"

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
          coverage: [1, 2, nil] of Int64?,
          format: "cobertura",
        ),
        CoverageReporter::FileReport.new(
          name: "app/helper.cr",
          coverage: [5, nil, 43] of Int64?,
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
    WebMock.stub(:post, endpoint).with(
      headers: {
        "Content-Type"                 => "application/json",
        "X-Coveralls-Reporter"         => "coverage-reporter",
        "X-Coveralls-Reporter-Version" => CoverageReporter::VERSION,
        "X-Coveralls-Coverage-Formats" => "cobertura",
        "X-Coveralls-Files"            => "cobertura.xml",
        "X-Coveralls-Source"           => "cli",
      },
      body: {
        :json => config.to_h.merge({
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
        }).to_json.to_s,
      }.to_json,
    ).to_return(status: 200, body: {:result => "ok"}.to_json)

    subject.send_request
  end
end
