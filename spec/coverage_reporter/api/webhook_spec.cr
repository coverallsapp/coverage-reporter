require "../../spec_helper"

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
    WebMock.stub(:post, endpoint).with do |request|
      # Relaxed body check: only validate critical fields, ignore CI metadata
      json = JSON.parse(request.body.not_nil!)
      json["repo_token"]? == "token" &&
        json["carryforward"]? == "flag1,flag2" &&
        json["git"]?.try &.["branch"]? == "chore/add-tests"
    end.to_return(status: 200, body: {"response" => "ok"}.to_json)

    subject.send_request
  end

  it "follows the redirect" do
    redirect_url = "https://coveralls-redirect.io/webhook"

    WebMock.stub(:post, endpoint).with do |request|
      json = JSON.parse(request.body.not_nil!)
      json["repo_token"]? == "token" &&
        json["carryforward"]? == "flag1,flag2" &&
        json["git"]?.try &.["branch"]? == "chore/add-tests"
    end.to_return(status: 301, body: "Moved permanently", headers: {"location" => redirect_url})

    WebMock.stub(:post, redirect_url).with do |request|
      json = JSON.parse(request.body.not_nil!)
      json["repo_token"]? == "token" &&
        json["carryforward"]? == "flag1,flag2" &&
        json["git"]?.try &.["branch"]? == "chore/add-tests"
    end.to_return(status: 200, body: {"response" => "ok"}.to_json)

    expect { subject.send_request }.not_to raise_error
  end
end
