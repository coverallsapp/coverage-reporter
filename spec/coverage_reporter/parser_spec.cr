require "../spec_helper"

Spectator.describe CoverageReporter::Parser do
  describe "#parse" do
    context "for exact file" do
      subject { described_class.new("spec/fixtures/test.lcov") }

      it "returns reports for one file" do
        reports = subject.parse

        expect(reports.size).to eq 1
      end
    end
    context "for all files" do
      subject { described_class.new(nil) }

      it "returns reports for all files" do
        reports = subject.parse

        expect(reports.size).to eq 6
      end
    end
  end
end
