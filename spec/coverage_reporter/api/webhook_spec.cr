require "../../spec_helper"

Spectator.describe CoverageReporter::Api::Webhook do
  subject { described_class.new(config) }

  let(config) { CoverageReporter::Config.new("token") }
  let(endpoint) { "#{CoverageReporter::Api::DEFAULT_DOMAIN}/webhook" }

  before_all do
    CoverageReporter::Log.set(CoverageReporter::Log::Level::Error)
  end

  after_each { WebMock.reset }

  it "calls the /webhook endpoint" do
    WebMock.stub(:post, endpoint).with(
      headers: {"Content-Type" => "application/json"},
      body: {
        :repo_token => "token",
        :payload    => {
          :build_num => nil,
          :status    => "done",
        },
      }.to_json
    ).to_return(status: 200, body: {"response" => "ok"}.to_json)

    subject.send_request
  end
end
