require "../spec_helper"

Spectator.describe CoverageReporter::Reporter do
  subject do
    described_class.new(
      coverage_file: coverage_file,
      base_path: base_path,
      repo_token: repo_token,
      config_path: config_path,
      compare_ref: compare_ref,
      job_flag_name: job_flag_name,
      carryforward: carryforward,
      parallel: parallel,
      dry_run: false,
      overrides: nil,
    )
  end

  let(coverage_file) { nil }
  let(base_path) { nil }
  let(repo_token) { "test-token" }
  let(config_path) { nil }
  let(compare_ref) { nil }
  let(job_flag_name) { nil }
  let(carryforward) { nil }
  let(parallel) { false }

  describe "#report" do
    let(endpoint) { "https://coveralls.io" }

    before_each do
      WebMock.stub(:post, "#{endpoint}/api/v1/jobs")
    end

    after_each { WebMock.reset }

    it "doesn't raise an error" do
      expect { subject.report }.not_to raise_error
    end

    context "when COVERALLS_ENDPOINT is defined" do
      let(endpoint) { "https://example.com" }

      before_each do
        ENV["COVERALLS_ENDPOINT"] = "https://example.com"
      end

      after_each { ENV.clear }

      it "doesn't raise an error" do
        expect { subject.report }.not_to raise_error
      end
    end

    context "local development" do
      let(endpoint) { "http://localhost:3000" }

      before_each do
        ENV["COVERALLS_DEVELOPMENT"] = "1"
      end

      after_each { ENV.clear }

      it "doesn't raise an error" do
        expect { subject.report }.not_to raise_error
      end
    end

    context "when report is empty" do
      let(coverage_file) { "spec/fixtures/lcov/empty.lcov" }

      it "raises NoSourceFiles" do
        expect { subject.report }
          .to raise_error(CoverageReporter::Reporter::NoSourceFiles)
      end
    end
  end

  describe "#parallel_done" do
    let(endpoint) { "https://coveralls.io" }

    before_each do
      WebMock.stub(:post, "#{endpoint}/webhook")
    end

    after_each { WebMock.reset }

    it "doesn't raise an error" do
      expect { subject.parallel_done }.not_to raise_error
    end

    context "when COVERALLS_ENDPOINT is defined" do
      let(endpoint) { "https://example.com" }

      before_each do
        ENV["COVERALLS_ENDPOINT"] = "https://example.com"
      end

      after_each { ENV.clear }

      it "doesn't raise an error" do
        expect { subject.parallel_done }.not_to raise_error
      end
    end
  end
end
