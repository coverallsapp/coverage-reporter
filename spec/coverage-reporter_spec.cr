require "./spec_helper"

describe CoverageReporter do
  describe "run" do
    before_all do
      WebMock.stub(:post, "https://coveralls.io/api/v1/jobs")
      WebMock.stub(:post, "https://coveralls.io/webhook")

      CoverageReporter.quiet!
    end

    context "default environment" do
      it "runs" do
        repo_token = "asdfasdf"
        filename = ""
        config_path = ""
        job_flag = "unit"
        parallel = true

        res = CoverageReporter.run filename, repo_token, config_path, job_flag, parallel
        res.should be_true
      end

      it "handles webhook" do
        repo_token = "asdfasdf"

        res = CoverageReporter.parallel_finished repo_token, ""
        res.should be_true
      end
    end
  end
end
