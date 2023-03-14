require "../spec_helper"

Spectator.describe CoverageReporter::Parser do
  describe "#parse" do
    context "for exact file" do
      subject { described_class.new("spec/fixtures/lcov/test.lcov", nil) }

      it "returns reports for one file" do
        reports = subject.parse

        expect(reports.size).to eq 1
      end

      context "for non-existing file" do
        subject { described_class.new("spec/fixtures/oops/coverage", nil) }

        it "raises error" do
          expect { subject.parse }
            .to raise_error(CoverageReporter::Parser::NotFound)
        end
      end

      context "for an unknown file format" do
        subject { described_class.new("spec/fixtures/lcov/test.js", nil) }

        it "returns reports for one file" do
          reports = subject.parse

          expect(reports.size).to eq 0
        end
      end
    end

    context "for all files" do
      subject { described_class.new(nil, nil) }

      it "returns reports for all files" do
        reports = subject.parse

        expect(reports.size).to be > 1
      end
    end
  end
end
