require "../../spec_helper"

Spectator.describe CoverageReporter::Api::Jobs do
  subject { described_class.new(config, parallel, source_files, git_info) }

  let(config) { CoverageReporter::Config.new("token") }
  let(parallel) { false }
  let(git_info) { {:branch => "chore/add-tests", :head => {:message => "add tests"}} }
  let(source_files) do
    [
      CoverageReporter::FileReport.new(
        name: "app/main.cr",
        coverage: [1, 2, nil],
      ),
      CoverageReporter::FileReport.new(
        name: "app/helper.cr",
        coverage: [5, nil, 43],
      ),
    ]
  end

  let(endpoint) { "#{CoverageReporter::Api::DEFAULT_DOMAIN}/api/#{CoverageReporter::Api::API_VERSION}/jobs" }

  before_all do
    CoverageReporter::Log.set(CoverageReporter::Log::Level::Error)
  end

  after { WebMock.reset }

  it "calls the /jobs endpoint" do
    WebMock.stub(:post, endpoint).with(
      headers: {"Content-Type" => "application/json"},
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
        }).to_json.to_s,
      }.to_json,
    ).to_return(status: 200, body: {:result => "ok"}.to_json)

    subject.send_request
  end
end
