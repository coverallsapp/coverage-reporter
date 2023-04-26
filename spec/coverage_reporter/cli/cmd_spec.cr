require "../../spec_helper"
require "../../../src/coverage_reporter/cli/cmd"

Spectator.describe CoverageReporter::Cli do
  subject { described_class }

  before_each do
    ENV["COVERALLS_REPO_TOKEN"] = "test-token"
  end

  after_each { ENV.clear }

  describe ".run" do
    it "applies defaults" do
      reporter = subject.run %w(--dry-run)

      expect(reporter.fail_empty).to eq true
      expect(reporter.dry_run).to eq true
      expect(reporter.parallel).to eq false
    end

    it "parses overrides" do
      reporter = subject.run %w(--service-name overriden --dry-run --no-logo)

      expect(reporter.dry_run).to eq true
      expect(reporter.overrides.try(&.to_h)).to eq({
        :service_name => "overriden",
      })
    end

    it "doesn't apply empty values as overrides" do
      reporter = subject.run %w(
        --service-name=
        --service-job-id=
        --service-build-url=
        --service-job-url=
        --service-branch=
        --service-pull-request=
        --done
        --dry-run
      )

      expect(reporter.dry_run).to eq true
      expect(reporter.overrides.try(&.to_h)).to eq({} of Symbol => String)
    end

    it "accepts --allow-empty option" do
      reporter = subject.run %w(
        --allow-empty
        --dry-run
      )

      expect(reporter.fail_empty).to eq false
    end

    it "accepts --carryforward option" do
      reporter = subject.run %w(
        --carryforward "1,2,3"
        --dry-run
      )

      expect(reporter.carryforward).to eq "\"1,2,3\""
    end

    it "accepts --format option" do
      reporter = subject.run %w(
        --format lcov
        --file spec/fixtures/lcov/test.lcov
        --dry-run
      )

      expect(reporter.coverage_format).to eq "lcov"
    end

    it "accepts --filename option" do
      reporter = subject.run %w(
        --file spec/fixtures/lcov/test.lcov
        --dry-run
      )

      expect(reporter.coverage_file).to eq "spec/fixtures/lcov/test.lcov"
    end
  end
end
