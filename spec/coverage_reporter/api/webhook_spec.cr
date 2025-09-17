require "../../spec_helper"

# Debug helper: log all WebMock requests during this spec file
WebMock.after_request do |request, response|
  puts ">>> WebMock saw: #{request.method} #{request.uri}"
  if response.nil?
    puts "    (no stub matched — would hit network!)"
  end
end

Spectator.describe CoverageReporter::Api::Webhook do
  subject { described_class.new(config, "flag1,flag2", git_info) }

  let(config) { CoverageReporter::Config.new("token") }
  let(git_info) { {:branch => "chore/add-tests", :head => {:message => "add tests"}} }
  let(endpoint) { "#{CoverageReporter::Config::DEFAULT_ENDPOINT}/webhook" }

  after_each { WebMock.reset }

  let(headers) do
    {
      "Content-Type"                 => "application/json",
      "X-Coveralls-Reporter"         => "coverage-reporter",
      "X-Coveralls-Reporter-Version" => CoverageReporter::VERSION,
      "X-Coveralls-Source"           => "cli",
    }
  end

  let(body) do
    {
      :repo_token   => "token",
      :carryforward => "flag1,flag2",
      :payload      => {
        :build_num => nil,
        :status    => "done",
      },
      :git => {
        :branch => "chore/add-tests",
        :head   => {
          :message => "add tests",
        },
      },
    }.to_json
  end

  it "calls the /webhook endpoint" do
    WebMock.stub(:post, endpoint).with(
      headers: headers,
      body: body
    ).to_return(status: 200, body: {"response" => "ok"}.to_json)

    subject.send_request
  end

  it "follows the redirect" do
    redirect_url = "https://coveralls-redirect.io/webhook"

    WebMock.stub(:post, endpoint).with(
      headers: headers,
      body: body,
    ).to_return(status: 301, body: "Moved permanently", headers: {"location" => redirect_url})

    WebMock.stub(:post, redirect_url).with(
      headers: headers,
      body: body
    ).to_return(status: 200, body: {"response" => "ok"}.to_json)

    expect { subject.send_request }.not_to raise_error
  end
end
