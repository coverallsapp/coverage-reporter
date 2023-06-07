require "../../spec_helper"
require "../../../src/coverage_reporter/cli/cmd"

Spectator.describe CoverageReporter::Cli do
  subject { described_class }

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

    it "parses overrides" do
      reporter = subject.run %w(
        report
        --parallel
        -j super-flag
        --base-path src/*
        --service-name=service-name
        --service-job-id=job-id
        --service-build-url=build-url
        --service-job-url=job-url
        --service-branch=branch
        --service-pull-request=pr
        --build-number=build-number
        --compare-ref=develop
        --dry-run
      )

      expect(reporter.job_flag_name).to eq "super-flag"
      expect(reporter.parallel).to eq true
      expect(reporter.compare_ref).to eq "develop"
      expect(reporter.dry_run).to eq true
      expect(reporter.base_path).to eq "src/*"
      expect(reporter.overrides.try(&.to_h)).to eq({
        :service_name         => "service-name",
        :service_number       => "build-number",
        :service_job_id       => "job-id",
        :service_build_url    => "build-url",
        :service_job_url      => "job-url",
        :service_branch       => "branch",
        :service_pull_request => "pr",
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
        --carryforward 1,2,3
        --dry-run
      )

      expect(reporter.carryforward).to eq "1,2,3"
    end

    it "accepts --carryforward option" do
      reporter = subject.run %w(
        done
        --build-number 3
        --carryforward 1,2,3
        --dry-run
      )

      expect(reporter.carryforward).to eq "1,2,3"
      expect(reporter.overrides.try(&.to_h)).to eq({
        :service_number => "3",
      })
    end

    it "accepts --format option" do
      reporter = subject.run %w(
        --format lcov
        --dry-run
      )

      expect(reporter.coverage_format).to eq "lcov"
    end

    it "accepts --filename option" do
      reporter = subject.run %w(
        --file spec/fixtures/lcov/test.lcov
        --dry-run
      )

      expect(reporter.coverage_files).to eq ["spec/fixtures/lcov/test.lcov"]
    end

    it "reports multiple files" do
      reporter = subject.run %w(
        report
        spec/fixtures/lcov/test.lcov
        spec/fixtures/lcov/test.lcov
        spec/fixtures/lcov/empty.lcov
        --dry-run
      )

      expect(reporter.coverage_files).to eq [
        "spec/fixtures/lcov/test.lcov",
        "spec/fixtures/lcov/empty.lcov",
      ]
    end

    it "reports multiple files after --" do
      reporter = subject.run %w(
        report
        --dry-run
        --
        spec/fixtures/lcov/test.lcov
        spec/fixtures/lcov/test.lcov
        spec/fixtures/lcov/empty.lcov
      )

      expect(reporter.coverage_files).to eq [
        "spec/fixtures/lcov/test.lcov",
        "spec/fixtures/lcov/empty.lcov",
      ]
    end
  end
end
