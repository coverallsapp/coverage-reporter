require "../../spec_helper"

Spectator.describe CoverageReporter::GcovParser do
  subject { described_class.new(base_path) }

  let(base_path) { nil }

  describe "#matches?" do
    it "matches only .gcov files" do
      expect(subject.matches?(".gcov")).to eq true
      expect(subject.matches?("main.c.gcov")).to eq true
      expect(subject.matches?("some-path/file.gcov")).to eq true
      expect(subject.matches?("main.c.lcov")).to eq false
    end
  end

  describe "#parse" do
    let(filename) { "spec/fixtures/gcov/main.c.gcov" }

    it "parses gcov" do
      result = subject.parse(filename)

      expect(result[0].to_h).to eq({
        :name     => "main.c",
        :coverage => [nil, nil, 2, nil, 2, 1, 1, 1, nil, 0, nil, 2, nil, nil, 1, nil, 1, 1, 1, nil],
      })
    end

    context "with base_path" do
      let(base_path) { "spec/fixtures/gcov" }

      it "parses gcov with source digest" do
        result = subject.parse(filename)

        expect(result[0].to_h).to eq({
          :name          => "spec/fixtures/gcov/main.c",
          :coverage      => [nil, nil, 2, nil, 2, 1, 1, 1, nil, 0, nil, 2, nil, nil, 1, nil, 1, 1, 1, nil],
          :source_digest => "da803fdb1b06abe64c3b806d861a5baa",
        })
      end
    end
  end
end
