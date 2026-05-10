require "../../spec_helper"

Spectator.describe CoverageReporter::LuaCovParser do
  subject { described_class.new(nil) }

  describe "#matches?" do
    it "matches correct filenames" do
      expect(subject.matches?("spec/fixtures/luacov/single-file/luacov.report.out")).to eq true
      expect(subject.matches?("spec/fixtures/luacov/two-files/luacov.report.out")).to eq true
      expect(subject.matches?("spec/fixtures/luacov/first-header-content-empty/luacov.report.out")).to eq false
      expect(subject.matches?("spec/fixtures/luacov/first-header-line-mismatch/luacov.report.out")).to eq false
      expect(subject.matches?("spec/fixtures/luacov/first-header-without-bottom-line/luacov.report.out")).to eq false
      expect(subject.matches?("spec/fixtures/luacov/first-header-without-content/luacov.report.out")).to eq false
      expect(subject.matches?("spec/fixtures/luacov/first-header-without-top-line/luacov.report.out")).to eq false
      expect(subject.matches?("spec/fixtures/test.lcov")).to eq false
      expect(subject.matches?("some-non-existing-file.out")).to eq false
    end
  end

  describe "#parse" do
    let(filename1) { "spec/fixtures/luacov/single-file/luacov.report.out" }

    it "parses the data correctly with a single file reported" do
      reports = subject.parse(filename1)
      expect(reports.size).to eq 1

      sample = reports.find! do |r|
        r.name == "test.lua"
      end

      expect(sample.coverage).to eq [
        nil, nil, 1, nil, 0, nil, 11, 10, 1, nil, 9, nil, nil, 1, 1, nil, 0, nil, nil, nil,
      ] of UInt64?
    end

    let(filename2) { "spec/fixtures/luacov/two-files/luacov.report.out" }

    it "parses the data correctly with many files reported" do
      reports = subject.parse(filename2)
      expect(reports.size).to eq 2

      sample = reports.find! do |r|
        r.name == "my-lib.lua"
      end

      expect(sample.coverage).to eq [
        nil, nil, nil, 1, nil, 0, nil, nil, nil,
      ] of UInt64?

      sample = reports.find! do |r|
        r.name == "test.lua"
      end

      expect(sample.coverage).to eq [
        nil, nil, 1, nil, 0, nil, 11, 10, 1, nil, 9, nil, nil, 1, 1, nil, 0, nil, nil, nil,
      ] of UInt64?
    end

    let(filename3) { "spec/fixtures/luacov/line-info-too-many-hits/luacov.report.out" }

    it "does not parse the data containing lines with too many hits" do
      reports = subject.parse(filename3)
      expect(reports.size).to eq 0
    end

    let(filename4) { "spec/fixtures/luacov/second-header-content-empty/luacov.report.out" }

    it "does not parse the data when the content in the second header is empty" do
      reports = subject.parse(filename4)
      expect(reports.size).to eq 0
    end

    let(filename5) { "spec/fixtures/luacov/second-header-line-mismatch/luacov.report.out" }

    it "does not parse the data when the top line is different from the bottom line in the second header" do
      reports = subject.parse(filename5)
      expect(reports.size).to eq 0
    end

    let(filename6) { "spec/fixtures/luacov/second-header-without-bottom-line/luacov.report.out" }

    it "does not parse the data when the second header is missing the bottom line" do
      reports = subject.parse(filename6)
      expect(reports.size).to eq 0
    end

    let(filename7) { "spec/fixtures/luacov/second-header-without-content/luacov.report.out" }

    it "does not parse the data when the content in the second header is missing" do
      reports = subject.parse(filename7)
      expect(reports.size).to eq 0
    end
  end
end
