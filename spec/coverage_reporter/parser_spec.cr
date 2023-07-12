require "../spec_helper"

Spectator.describe CoverageReporter::Parser do
  subject { described_class.new(coverage_files, coverage_format, base_path) }

  let(coverage_files) { nil }
  let(coverage_format) { nil }
  let(base_path) { nil }

  describe "#parse" do
    context "for exact file" do
      let(coverage_files) { ["spec/fixtures/lcov/test.lcov"] }

      it "returns reports for one file" do
        reports = subject.parse

        expect(reports.size).to eq 2
      end

      context "for non-existing file" do
        let(coverage_files) { ["spec/fixtures/oops/coverage"] }

        it "raises error" do
          expect { subject.parse }
            .to raise_error(CoverageReporter::Parser::NotFound)
        end
      end

      context "for an unknown file format" do
        let(coverage_files) { ["spec/fixtures/lcov/index.js"] }

        it "returns an empty report" do
          reports = subject.parse

          expect(reports.size).to eq 0
        end
      end

      context "when coverage format forced" do
        let(coverage_format) { "lcov" }

        it "returns report only for specified format" do
          reports = subject.parse

          expect(reports.size).to eq 2
        end

        context "when a file is specified" do
          let(coverage_files) { ["spec/fixtures/lcov/for-base-path-lcov"] }
          let(base_path) { "spec/fixtures/lcov" }

          it "returns report only for specified file" do
            reports = subject.parse

            expect(reports.size).to eq 2
          end
        end

        context "when another format file specified" do
          let(coverage_files) { ["spec/fixtures/gcov/main.c.gcov"] }

          it "returns empty report" do
            reports = subject.parse

            expect(reports.size).to eq 0
          end
        end
      end

      context "for unknown coverage format" do
        let(coverage_format) { "unknown" }

        it "raises error" do
          expect { subject.parse }
            .to raise_error(CoverageReporter::Parser::InvalidCoverageFormat)
        end
      end
    end

    context "for all files" do
      it "returns reports for all files" do
        reports = subject.parse

        expect(reports.size).to be > 2
      end
    end
  end
end
