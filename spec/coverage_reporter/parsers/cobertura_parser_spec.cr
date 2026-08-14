require "../../spec_helper"

Spectator.describe CoverageReporter::CoberturaParser do
  subject { described_class.new(base_path) }

  let(base_path) { nil }

  describe "#globs" do
    it "finds all cobertura files" do
      expect(Dir[subject.globs]).to contain(
        "spec/fixtures/cobertura/cobertura.xml",
        "spec/fixtures/cobertura/cobertura-coverage.xml",
      )
    end
  end

  describe "#matches?" do
    it "matches correct filenames" do
      expect(subject.matches?("cobertura.xml")).to eq false
      expect(subject.matches?("spec/fixtures/cobertura/cobertura.xml")).to eq true
      expect(subject.matches?("spec/fixtures/cobertura/cobertura-oneline.xml")).to eq true
      expect(subject.matches?("spec/fixtures/jacoco/jacoco-report.xml")).to eq false
      expect(subject.matches?("spec/fixtures/jacoco/jacoco-oneline-report.xml")).to eq false
    end
  end

  describe "#parse" do
    let(filename) { "spec/fixtures/cobertura/cobertura.xml" }

    it "parses the data correctly" do
      reports = subject.parse(filename)

      expect(reports.size).to eq 16
      expect(reports[0].name).to match /^org\/scoverage\//
      with_branches = reports.find! do |report|
        report.name == "org/scoverage/samples/SimpleObject2.scala"
      end

      expect(with_branches.coverage).to eq [
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 1, nil, nil,
        0, nil, 0, nil, 1, nil, 1, 0, 0, 0, nil, nil, nil, nil, 1, 0, 0, 1, 1,
      ] of UInt64?
      expect(with_branches.branches).to eq [
        15, 1, 0, 0,
        17, 2, 0, 0,
        19, 3, 0, 1,
        21, 4, 0, 1,
        22, 5, 0, 0,
        30, 6, 0, 0,
        31, 7, 0, 0,
        32, 8, 0, 1,
        33, 9, 0, 1,
      ] of UInt64?

      with_branches_on_one_line = reports.find! do |report|
        report.name == "org/scoverage/samples/InstrumentLoader.scala"
      end
      expect(with_branches_on_one_line.coverage).to eq [
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 1, nil, nil, 1, nil, 1,
      ] of UInt64?
      expect(with_branches_on_one_line.branches).to eq [
        12, 1, 0, 1,
        12, 2, 1, 0,
      ] of UInt64?
    end

    context "with base_path" do
      let(base_path) { "src/main/scala" }

      it "joins with base_path" do
        reports = subject.parse(filename)

        expect(reports[0].name).to match /^src\/main\/scala\/org\/scoverage\//
      end
    end

    # -------------------------------------------------------------------
    # Edge case regression tests (fixtures live in spec/fixtures/cobertura/)
    #
    # These cover the bug we fixed in Sept 2025 where the parser crashed
    # with "Arithmetic overflow (OverflowError)" when max_line == 0.
    #
    #   • cobertura-empty-lines.xml
    #       A class with no <line> entries at all.
    #       Previously this triggered (1..0) → overflow.
    #
    #   • cobertura-zero-only.xml
    #       A class with only line number="0" entries.
    #       Also produced max_line = 0 → overflow.
    #
    # Both files are tiny repros extracted from the real-world case
    # (kvstore/__init__.py inside a 14.3MB report (1 of 32) titled coverage-8.xml).
    # -------------------------------------------------------------------
    context "edge cases: empty and zero-only classes" do
      it "parses a class with no <line> entries (no overflow)" do
        reports = subject.parse("spec/fixtures/cobertura/cobertura-empty-lines.xml")
        expect(reports.size).to eq 1
        # Should not raise; coverage array may be empty and that's OK.
      end

      it "parses a class with only line number='0' entries (no overflow)" do
        reports = subject.parse("spec/fixtures/cobertura/cobertura-zero-only.xml")
        expect(reports.size).to eq 1
        # Should not raise; zero-numbered lines are ignored safely.
      end
    end
  end
end
