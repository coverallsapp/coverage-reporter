require "../../spec_helper"

Spectator.describe CoverageReporter::GolangParser do
  subject { described_class.new(nil) }

  describe "#matches?" do
    it "matches correct filenames" do
      expect(subject.matches?("spec/fixtures/golang/coverage.out")).to eq true
      expect(subject.matches?("spec/fixtures/test.lcov")).to eq false
      expect(subject.matches?("some-non-existing-file.out")).to eq false
    end
  end

  describe "#parse" do
    let(filename) { "spec/fixtures/golang/coverage.out" }

    it "parses the data correctly" do
      reports = subject.parse(filename)
      expect(reports.size).to eq 27

      sample = reports.find! do |r|
        r.name == "internal/config/hook.go"
      end

      expect(sample.coverage).to eq [
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, 0, 0, 0, 0, nil, 0, nil, nil, 0, 0, 0, 0, 0, nil, nil, 1, 2, 1, 1,
        nil, 1, 1, 0, 0, nil, 1, 1, 0, 0, nil, 1, 1, 1, 1, 1, 2, 1, 3, 1, 0, 0, nil, nil,
        1, 0, 0, nil, 1, 0, 0, nil, 1,
      ] of Int64?
    end
  end
end
