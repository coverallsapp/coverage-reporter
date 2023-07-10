require "../../spec_helper"
require "../../../src/coverage_reporter/cli/cmd"

Spectator.describe CoverageReporter::Cli do
  subject { described_class.run(options, reporter) }

  let(reporter) { ReporterMock.new }

  describe ".run" do
    context "defaults" do
      let(options) { %w(--dry-run) }

      it "applies defaults" do
        expect(subject).to eq 0
        expect(reporter.fail_empty).to eq true
        expect(reporter.dry_run).to eq true
        expect(reporter.parallel).to eq false
      end
    end

    context "with overrides" do
      let(options) { %w(--service-name overriden --dry-run --no-logo) }

      it "parses overrides" do
        expect(subject).to eq 0
        expect(reporter.dry_run).to eq true
        expect(reporter.overrides.try(&.to_h)).to eq({
          :service_name => "overriden",
        })
      end
    end

    context "with more overrides" do
      let(options) do
        %w(
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
      end

      it "parses overrides" do
        expect(subject).to eq 0
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
    end

    context "with new args" do
      let(options) do
        %w(
          report
          --parallel
          -j super-flag
          --base-path src/*
          --service-name=service-name
          --job-id=job-id
          --build-url=build-url
          --job-url=job-url
          --branch=branch
          --pull-request=pr
          --build-number=build-number
          --compare-ref=develop
          --attempt=4
          --dry-run
        )
      end

      it "parses overrides (new args)" do
        expect(subject).to eq 0
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
          :service_attempt      => "4",
        })
      end
    end

    context "with empty values" do
      let(options) do
        %w(
          --service-name=
          --service-job-id=
          --service-build-url=
          --service-job-url=
          --service-branch=
          --service-pull-request=
          --done
          --dry-run
        )
      end
      it "doesn't apply empty values as overrides" do
        expect(subject).to eq 0
        expect(reporter.dry_run).to eq true
        # expect(reporter.overrides.try(&.to_h)).to eq({} of Symbol => String)
      end
    end

    context "with allow empty option" do
      let(options) do
        %w(
          --allow-empty
          --dry-run
        )
      end
      it "accepts --allow-empty option" do
        expect(subject).to eq 0
        expect(reporter.fail_empty).to eq false
      end
    end

    context "with carryforward option" do
      let(options) do
        %w(
          --carryforward 1,2,3
          --dry-run
        )
      end

      it "accepts --carryforward option" do
        expect(subject).to eq 0
        expect(reporter.carryforward).to eq "1,2,3"
      end
    end

    context "with carryforward (new args)" do
      let(options) do
        %w(
          done
          --build-number 3
          --carryforward 1,2,3
          --dry-run
        )
      end

      it "accepts --carryforward option" do
        expect(subject).to eq 0
        expect(reporter.carryforward).to eq "1,2,3"
        expect(reporter.overrides.try(&.to_h)).to eq({
          :service_number => "3",
        })
      end
    end

    context "with format option" do
      let(options) do
        %w(
          --format lcov
          --dry-run
        )
      end

      it "accepts --format option" do
        expect(subject).to eq 0
        expect(reporter.coverage_format).to eq "lcov"
      end
    end

    context "with filename option" do
      let(options) do
        %w(
          --file spec/fixtures/lcov/test.lcov
          --dry-run
        )
      end

      it "accepts --filename option" do
        expect(subject).to eq 0
        expect(reporter.coverage_files).to eq ["spec/fixtures/lcov/test.lcov"]
      end
    end

    context "with multiple files report" do
      let(options) do
        %w(
          report
          spec/fixtures/lcov/test.lcov
          spec/fixtures/lcov/test.lcov
          spec/fixtures/lcov/empty.lcov
          --dry-run
        )
      end

      it "reports multiple files" do
        expect(subject).to eq 0
        expect(reporter.coverage_files).to eq [
          "spec/fixtures/lcov/test.lcov",
          "spec/fixtures/lcov/empty.lcov",
        ]
      end
    end

    context "with -- separator" do
      let(options) do
        %w(
          report
          --dry-run
          --
          spec/fixtures/lcov/test.lcov
          spec/fixtures/lcov/test.lcov
          spec/fixtures/lcov/empty.lcov
        )
      end

      it "reports multiple files after --" do
        expect(subject).to eq 0
        expect(reporter.coverage_files).to eq [
          "spec/fixtures/lcov/test.lcov",
          "spec/fixtures/lcov/empty.lcov",
        ]
      end
    end

    context "when raises an error" do
      mock ReporterMock

      let(reporter) { mock(ReporterMock) }
      let(options) { %w(report) }

      context "internal server error" do
        let(error) do
          CoverageReporter::Api::InternalServerError.new(HTTP::Client::Response.new(500, ""))
        end

        it "returns 1" do
          allow(reporter).to receive(:report).and_raise(error)
          expect(subject).to eq 1
        end
      end

      context "unprocessable entity" do
        let(error) do
          CoverageReporter::Api::UnprocessableEntity.new(HTTP::Client::Response.new(422, ""))
        end

        it "returns 1" do
          allow(reporter).to receive(:report).and_raise(error)
          expect(subject).to eq 1
        end
      end

      context "other HTTP error" do
        let(error) do
          CoverageReporter::Api::HTTPError.new(HTTP::Client::Response.new(403, ""))
        end

        it "returns 1" do
          allow(reporter).to receive(:report).and_raise(error)
          expect(subject).to eq 1
        end
      end

      context "internal logic error" do
        let(error) do
          CoverageReporter::BaseException.new
        end

        it "returns 1" do
          allow(reporter).to receive(:report).and_raise(error)
          expect(subject).to eq 1
        end
      end

      context "internal logic error (with don't fail flag)" do
        let(error) do
          CoverageReporter::BaseException.new(fail: false)
        end

        it "returns 0" do
          allow(reporter).to receive(:report).and_raise(error)
          expect(subject).to eq 0
        end
      end

      context "any other error" do
        let(error) do
          Exception.new
        end

        it "returns 1" do
          allow(reporter).to receive(:report).and_raise(error)
          expect(subject).to eq 1
        end
      end
    end
  end
end
