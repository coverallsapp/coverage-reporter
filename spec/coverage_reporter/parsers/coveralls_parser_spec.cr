require "../../spec_helper"

Spectator.describe CoverageReporter::CoverallsParser do
  subject { described_class.new(base_path) }

  let(base_path) { nil }

  describe "#matches?" do
    it "matches only coveralls.json" do
      expect(subject.matches?("spec/fixtures/jacoco/jacoco-report.xml")).to eq false
      expect(subject.matches?("spec/fixtures/coveralls/coveralls.json")).to eq true
    end
  end

  describe "#parse" do
    let(filename) { "spec/fixtures/coveralls/coveralls.json" }

    it "parses" do
      result = subject.parse(filename)

      expect(result[0].to_h).to eq({
        :name          => "file.cpp",
        :coverage      => [nil, nil, 1, 1, 1, nil, 1, 1, 1],
        :branches      => [] of Array(Int64?),
        :source_digest => "74a2a8e2849b4ebf97c08c3da0d83703",
      })
    end

    context "with base_path" do
      let(base_path) { "spec/fixtures/gcov" }

      it "parses" do
        result = subject.parse(filename)

        expect(result[0].to_h).to eq({
          :name          => "#{base_path}/file.cpp",
          :coverage      => [nil, nil, 1, 1, 1, nil, 1, 1, 1],
          :branches      => [] of Array(Int64?),
          :source_digest => "74a2a8e2849b4ebf97c08c3da0d83703",
        })
      end
    end
  end
end
