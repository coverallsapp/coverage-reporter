require "../spec_helper"

Spectator.describe CoverageReporter::Reporter do
  subject do
    described_class.new(
      base_path: base_path,
      carryforward: carryforward,
      compare_ref: compare_ref,
      compare_sha: compare_sha,
      config_path: config_path,
      coverage_file: coverage_file,
      coverage_format: coverage_format,
      dry_run: false,
      fail_empty: fail_empty,
      job_flag_name: job_flag_name,
      overrides: nil,
      parallel: parallel,
      repo_token: repo_token,
    )
  end

  let(base_path) { nil }
  let(carryforward) { nil }
  let(compare_ref) { nil }
  let(compare_sha) { nil }
  let(config_path) { nil }
  let(coverage_file) { nil }
  let(coverage_format) { nil }
  let(fail_empty) { true }
  let(job_flag_name) { nil }
  let(parallel) { false }
  let(repo_token) { "test-token" }

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

      it "makes it fail" do
        subject.report
      rescue ex : CoverageReporter::Reporter::NoSourceFiles
        expect(ex.fail?).to eq true
      end

      context "when fail_empty is false" do
        let(fail_empty) { false }

        it "doesn't fail" do
          subject.report
        rescue ex : CoverageReporter::Reporter::NoSourceFiles
          expect(ex.fail?).to eq false
        end
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
