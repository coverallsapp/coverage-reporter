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

        expect(reports.size).to eq 82
        expect(reports[0].name).to eq("home/jaanus/Git/unleash/src/lib/create-config.ts")

        with_branches = reports.find! do |report|
          report.name == "home/jaanus/Git/unleash/src/lib/create-config.ts"
        end

        # <line num="1" count="1" type="stmt"/>
        expect(with_branches.coverage[0]).to eq 1
        # no line
        expect(with_branches.coverage[3]).to eq nil
        # <line num="58" count="22" type="stmt"/>
        expect(with_branches.coverage[57]).to eq 22
        # <line num="217" count="2" type="cond" truecount="0" falsecount="1"/>
        expect(with_branches.coverage[216]).to eq 2
        # last line number
        # <line num="501" count="1" type="stmt"/>
        expect(with_branches.coverage.size).to eq 501

        # if with_branches.branches.is_a?(Array)
          # puts with_branches.branches.size
        # end
      end
    end
  end
end
