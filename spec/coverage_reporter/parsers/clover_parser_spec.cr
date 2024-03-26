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

  describe "#matches?" do
    it "matches correct filenames" do
      expect(subject.matches?("spec/fixtures/clover/clover-phpcsutils.xml")).to eq true
      expect(subject.matches?("spec/fixtures/clover/clover-unleash.xml")).to eq true
      expect(subject.matches?("spec/fixtures/clover/clover-untested-method.xml")).to eq true

      expect(subject.matches?("spec/fixtures/cobertura/cobertura.xml")).to eq false
      expect(subject.matches?("spec/fixtures/cobertura/cobertura-oneline.xml")).to eq false
      expect(subject.matches?("spec/fixtures/jacoco/jacoco-report.xml")).to eq false
      expect(subject.matches?("spec/fixtures/jacoco/jacoco-oneline-report.xml")).to eq false
    end
  end

  describe "#parse" do
    context "with clover-phpcsutils.xml" do
      let(filename) { "spec/fixtures/clover/clover-phpcsutils.xml" }

      it "parses the data correctly" do
        reports = subject.parse(filename)

        expect(reports.size).to eq 2
        expect(reports[0].name).to match /.*AbstractArrayDeclarationSniff.php/
        expect(reports[0].branches).to eq [] of UInt64?
      end
    end

    context "with clover-untested-method.xml" do
      let(filename) { "spec/fixtures/clover/clover-untested-method.xml" }

      it "parses the data correctly" do
        reports = subject.parse(filename)

        the_file = reports.find! do |report|
          report.name == "home/yu/projects/PHPCSUtils/PHPCSUtils/AbstractSniffs/AbstractArrayDeclarationSniff.php"
        end

        # <line num="1" type="method" name="process" visibility="public" complexity="4" crap="4" count="0"/>
        expect(the_file.coverage[0]).to eq(1)

        # <line num="2" type="stmt" count="0"/>
        expect(the_file.coverage[1]).to eq(0)
      end
    end

    context "with clover-unleash.xml" do
      let(filename) { "spec/fixtures/clover/clover-unleash.xml" }

      it "parses the data correctly" do
        reports = subject.parse(filename)

        expect(reports.size).to eq 2
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

        branches = with_branches.branches
        unless branches.nil?
          expect((branches.size / 4).to_i).to eq 35

          # <line num="48" count="1" type="cond" truecount="1" falsecount="1"/>
          expect(branches[0]).to eq 48
          expect(branches[1]).to eq 1

          # <line num="54" count="1" type="cond" truecount="2" falsecount="0"/>
          expect(branches[4]).to eq 54
          expect(branches[5]).to eq 2
        end
      end
    end
  end
end
