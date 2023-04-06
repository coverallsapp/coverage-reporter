require "../../spec_helper"

Spectator.describe CoverageReporter::Api::Webhook do
  subject { described_class.new(config, "flag1,flag2") }

  let(config) { CoverageReporter::Config.new("token") }
  let(endpoint) { "#{CoverageReporter::Config::DEFAULT_ENDPOINT}/webhook" }

  after_each { WebMock.reset }

  it "calls the /webhook endpoint" do
    WebMock.stub(:post, endpoint).with(
      headers: {"Content-Type" => "application/json"},
      body: {
        :repo_token   => "token",
        :carryforward => "flag1,flag2",
        :payload      => {
          :build_num => nil,
          :status    => "done",
        },
      }.to_json
    ).to_return(status: 200, body: {"response" => "ok"}.to_json)

    subject.send_request
  end
end
