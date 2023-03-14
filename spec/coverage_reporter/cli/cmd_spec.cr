require "../../spec_helper"
require "../../../src/coverage_reporter/cli/cmd"

Spectator.describe CoverageReporter::Cli do
  subject { described_class }

  before_each do
    ENV["COVERALLS_REPO_TOKEN"] = "test-token"
  end

  after_each { ENV.clear }

  describe ".run" do
    it "parses overrides" do
      reporter = subject.run %w(--service-name overriden --dry-run)

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
        --service-branch=
        --service-pull-request=
        --dry-run
      )

      expect(reporter.dry_run).to eq true
      expect(reporter.overrides.try(&.to_h)).to eq({} of Symbol => String)
    end
  end
end
