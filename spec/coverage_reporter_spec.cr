require "./spec_helper"

Spectator.describe CoverageReporter do
  before_all do
    CoverageReporter::Log.set(CoverageReporter::Log::Level::Error)
  end

  describe "report" do
    let(repo_token) { "asdfasdf" }
    let(filename) { nil }
    let(config_path) { "" }
    let(job_flag) { "unit" }
    let(parallel) { true }

    context "on coveralls.io" do
      before_all do
        WebMock.stub(:post, "https://coveralls.io/api/v1/jobs")
        WebMock.stub(:post, "https://coveralls.io/webhook")
      end

      after_all { WebMock.reset }

      it "posts coverage" do
        expect {
          CoverageReporter.report filename, repo_token, config_path, job_flag, parallel, false
        }.not_to raise_error
      end

      it "handles webhook" do
        expect { CoverageReporter.parallel_done repo_token, "", false }.not_to raise_error
      end
    end

    context "on Coveralls Enterprise" do
      before_all do
        WebMock.stub(:post, "https://example.com/api/v1/jobs")
        WebMock.stub(:post, "https://example.com/webhook")
        ENV["COVERALLS_ENDPOINT"] = "https://example.com"
      end

      after_all { WebMock.reset }

      it "posts coverage" do
        expect {
          CoverageReporter.report filename, repo_token, config_path, job_flag, parallel, false
        }.not_to raise_error
      end

      it "handles webhook" do
        expect {
          CoverageReporter.parallel_done repo_token, "", false
        }.not_to raise_error
      end
    end
  end
end
