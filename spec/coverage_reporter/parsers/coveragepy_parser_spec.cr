require "../../spec_helper"

Spectator.describe CoverageReporter::CoveragepyParser do
  subject { described_class.new(nil) }

  describe "#matches?" do
    context "when format is not forced" do
      it "matches only SQLite3 db file" do
        expect(subject.matches?("spec/fixtures/python/.coverage")).to eq true
        expect(subject.matches?("spec/fixtures/python/.coverage-non-existing")).to eq false
        expect(subject.matches?("spec/fixtures/golang/coverage.out")).to eq false
      end

      it "does not match if coverage program is not installed" do
        path = ENV["PATH"]
        ENV.delete("PATH")

        expect(subject.matches?("spec/fixtures/python/.coverage")).to be_falsey

        ENV["PATH"] = path
      end
    end

    context "when format is forced" do
      subject { described_class.new(nil, true) }

      it "raises error if coverage program is not installed" do
        path = ENV["PATH"]
        ENV.delete("PATH")

        expect { subject.matches?("spec/fixtures/python/.coverage") }.to raise_error(CoverageReporter::CoveragepyParser::ParserError)

        ENV["PATH"] = path
      end
    end
  end

  describe "#parse" do
    let(filename) { "spec/fixtures/python/.coverage" }

    context "with valid coverage file" do
      it "reads the coverage" do
        reports = subject.parse(filename)

        expect(reports.size).to be > 0
        expect(reports.map(&.to_h.transform_keys(&.to_s)))
          .to eq YAML.parse(File.read("#{__DIR__}/coveragepy_results.yml"))
      end
    end

    context "with invalid coverage file" do
      let(filename) { "spec/fixtures/simplecov/with-only-lines.resultset.json" }

      it "raises an error" do
        io_memory = IO::Memory.new("some error")

        expect { subject.parse(filename, io_memory) }.to raise_error(CoverageReporter::CoveragepyParser::ParserError, /some error/)
      end
    end
  end
end
