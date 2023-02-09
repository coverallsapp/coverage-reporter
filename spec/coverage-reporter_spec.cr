require "./spec_helper"

Spectator.describe CoverageReporter do
  before_all do
    CoverageReporter.quiet!
  end

  describe "run" do
    let(repo_token) { "asdfasdf" }
    let(filename) { "" }
    let(config_path) { "" }
    let(job_flag) { "unit" }
    let(parallel) { true }

    context "on coveralls.io" do
      before_all do
        WebMock.stub(:post, "https://coveralls.io/api/v1/jobs")
        WebMock.stub(:post, "https://coveralls.io/webhook")
      end

      it "posts coverage" do
        res = CoverageReporter.run filename, repo_token, config_path, job_flag, parallel
        expect(res).to be_true
      end

      it "handles webhook" do
        res = CoverageReporter.parallel_done repo_token, ""
        expect(res).to be_true
      end
    end

    context "on Coveralls Enterprise" do
      before_all do
        WebMock.stub(:post, "https://example.com/api/v1/jobs")
        WebMock.stub(:post, "https://example.com/webhook")
        ENV["COVERALLS_ENDPOINT"] = "https://example.com"
      end

      it "posts coverage" do
        res = CoverageReporter.run filename, repo_token, config_path, job_flag, parallel
        expect(res).to be_true
      end

      it "handles webhook" do
        res = CoverageReporter.parallel_done repo_token, ""
        expect(res).to be_true
      end
    end
  end
end
