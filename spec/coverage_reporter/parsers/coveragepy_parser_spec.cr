require "../../spec_helper"

Spectator.describe CoverageReporter::CoveragepyParser do
  subject { described_class.new(nil) }

  describe "#matches?" do
    it "matches only SQLite3 db file" do
      expect(subject.matches?("spec/fixtures/python/.coverage")).to eq true
      expect(subject.matches?("spec/fixtures/python/.coverage-non-existing")).to eq false
      expect(subject.matches?("spec/fixtures/golang/coverage.out")).to eq false
    end
  end

  describe "#parse" do
    let(filename) { "spec/fixtures/python/.coverage" }

    it "reads the coverage" do
      result = subject.parse(filename)

      expect(result.size).to eq 20
      expect(result.map(&.to_h.transform_keys(&.to_s)))
        .to eq YAML.parse(File.read("#{__DIR__}/coveragepy_results.yml"))
    end
  end
end
