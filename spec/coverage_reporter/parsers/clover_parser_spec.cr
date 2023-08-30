require "../../spec_helper"

Spectator.describe CoverageReporter::CloverParser do
  subject { described_class.new(base_path) }

  let(base_path) { nil }

  describe "#globs" do
    it "finds all cobertura files" do
      expect(Dir[subject.globs]).to contain(
        "spec/fixtures/clover/clover.xml",
      )
    end
  end

  # describe "#matches?" do
    # it "matches correct filenames" do
      # expect(subject.matches?("cobertura.xml")).to eq false
      # expect(subject.matches?("spec/fixtures/cobertura/cobertura.xml")).to eq true
      # expect(subject.matches?("spec/fixtures/cobertura/cobertura-oneline.xml")).to eq true
      # expect(subject.matches?("spec/fixtures/jacoco/jacoco-report.xml")).to eq false
      # expect(subject.matches?("spec/fixtures/jacoco/jacoco-oneline-report.xml")).to eq false
    # end
  # end

  describe "#parse" do
    context "with basic coverage" do
      let(filename) { "spec/fixtures/clover/clover.xml" }

      it "parses the data correctly" do
        reports = subject.parse(filename)

        expect(reports.size).to eq 1
        expect(reports[0].name).to match /.*BasicCalculator.php/
        expect(reports[0].branches).to eq [] of UInt64?
      end
    end

    context "with phpcsutils coverage" do
      let(filename) { "spec/fixtures/clover/clover-phpcsutils.xml" }

      it "parses the data correctly" do
        reports = subject.parse(filename)

        expect(reports.size).to eq 37
        expect(reports[0].name).to match /.*AbstractArrayDeclarationSniff.php/
        expect(reports[0].branches).to eq [] of UInt64?
      end
    end

    context "with unleash coverage" do
      let(filename) { "spec/fixtures/clover/clover-unleash.xml" }

      it "parses the data correctly" do
        reports = subject.parse(filename)

        expect(reports.size).to eq 1
        expect(reports[0].name).to match /.*BasicCalculator.php/
        with_branches = reports.find! do |report|
          # report.name == "org/scoverage/samples/SimpleObject2.scala"
          report.name == "home/yu/projects/example-php/calculator/BasicCalculator.php"
        end

        expect(with_branches.coverage).to eq [nil, nil, nil, nil, nil, 1, 1, nil, nil, 1, 1, nil, nil, 1, 1, nil, nil, 1, 1, 0, nil, 1] of UInt64?

        expect(with_branches.branches).to eq [] of UInt64?

        with_branches_on_one_line = reports.find! do |report|
          report.name.matches?(/.*BasicCalculator.php/)
        end
        expect(with_branches_on_one_line.coverage).to eq [
          nil, nil, nil, nil, nil, 1, 1, nil, nil, 1, 1, nil, nil, 1, 1, nil, nil, 1, 1, 0, nil, 1
        ] of UInt64?
        expect(with_branches_on_one_line.branches).to eq [] of UInt64?
      end
    end
  end
end
