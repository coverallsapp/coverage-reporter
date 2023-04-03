require "../../spec_helper"

Spectator.describe CoverageReporter::JacocoParser do
  subject { described_class.new(base_path) }

  let(base_path) { nil }

  describe "#matches?" do
    it "matches correct filenames" do
      expect(subject.matches?("spec/fixtures/jacoco/jacoco-report.xml")).to eq true
      expect(subject.matches?("spec/fixtures/cobertura/cobertura.xml")).to eq false
      expect(subject.matches?("non-existing.xml")).to eq false
    end
  end

  describe "#parse" do
    let(filename) { "spec/fixtures/jacoco/jacoco-report.xml" }

    it "parses the data correctly" do
      reports = subject.parse(filename)

      expect(reports.size).to eq 2
      expect(reports[0].name).to match /^com\/jacocodemo\//
      with_branches = reports.find! do |report|
        report.name == "com/jacocodemo/examples/MessageBuilder.java"
      end

      expect(with_branches.coverage).to eq [
        nil, nil, 3, nil, nil, nil, 4, nil, 6, nil, 0, nil, nil, nil, 11, nil, nil, 3,
      ] of Int64?
      expect(with_branches.branches).to eq [
        9, 1, 0, 1,
        9, 2, 1, 1,
        9, 3, 2, 0,
        9, 4, 3, 0,
      ] of Int64?
    end

    context "with base_path" do
      let(base_path) { "src/main/java" }

      it "joins with base_path" do
        reports = subject.parse(filename)

        expect(reports[0].name).to match /^src\/main\/java\/com\/jacocodemo\//
      end
    end
  end
end
