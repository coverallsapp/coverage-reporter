require "../../spec_helper"

Spectator.describe CoverageReporter::CoveragepyParser do
  subject { described_class.new(nil) }

  before_all do
    error = IO::Memory.new
    output = IO::Memory.new
    process_status = Process.run(
      command: "coverage run -m pytest",
      chdir: "spec/fixtures/python",
      shell: true,
      error: error,
      output: output
    )
    unless process_status.success?
      raise "Failed: #{error}\n#{output}"
    end
  end

  after_all do
    File.delete("spec/fixtures/python/.coverage")
  end

  describe "#matches?" do
    it "matches only SQLite3 db file" do
      expect(subject.matches?("spec/fixtures/python/.coverage")).to eq true
      expect(subject.matches?("spec/fixtures/python/.coverage-non-existing")).to eq false
      expect(subject.matches?("spec/fixtures/golang/coverage.out")).to eq false
    end
  end

  describe "#parse" do
    let(filename) { "spec/fixtures/python/.coverage" }

    context "with valid coverage file" do
      it "reads the coverage" do
        reports = subject.parse(filename)

        expect(reports.size).to eq 4
        expect(reports.map(&.to_h.transform_keys(&.to_s)))
          .to eq YAML.parse(File.read("#{__DIR__}/coveragepy_results.yml"))
      end
    end

    context "with invalid coverage file" do
      let(filename) { "spec/fixtures/simplecov/with-only-lines.resultset.json" }

      it "raises an error" do
        io_memory = IO::Memory.new("some error")

        expect { subject.parse(filename, io_memory) }.to raise_error(CoverageReporter::CoveragepyParser::ParserError, "some error")
      end
    end
  end
end
