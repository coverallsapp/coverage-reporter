require "../../spec_helper"

Spectator.describe CoverageReporter::LcovParser do
  subject { described_class.new(base_path) }

  let(base_path) { nil }

  describe "#matches?" do
    it "matches correct filenames" do
      expect(subject.matches?("somefile.lcov")).to eq true
      expect(subject.matches?("long/path/to/file.lcov")).to eq true
      expect(subject.matches?("long/path/to/file.lco")).to eq false

      expect(subject.matches?("lcov.info")).to eq true
      expect(subject.matches?("long/path/to/lcov.info")).to eq true
      expect(subject.matches?("heylcov.info")).to eq true
    end
  end

  describe "#parse" do
    let(filename) { "spec/fixtures/lcov/test.lcov" }
    let(coverage) do
      [1, 1, 1, nil, 1, 66, 66, nil, nil, 1, 323, 63, 63, 63, 60, nil, 3, nil, 63, 32,
       nil, 63, 63, 63, 3, nil, 63, 60, nil, 3, nil, 63, 27, 27, 27, nil, nil, 323, nil,
       nil, 1, 5, 5, nil, 2, nil, nil, 3, 3, 1, 1, 1, 1, nil, 0, nil, nil, 2, 2, 2, 0,
       nil, 2, nil, nil, 2, 2, nil, nil, nil, nil, 1, 1, 1, 1, 1, 1, nil, 1, 1, nil, 1,
       87, 87, 6, 6, 6, 6, 9, 6, 6, nil, 81, nil, nil, nil, 1, 1, nil, nil, 1, 1, nil,
       nil, 1, nil, 2, 2, 2, 1, nil, 2, nil, nil, 1, 3, 1, 1, nil, nil, 2, 2, 2, nil, 1,
       1, nil, 2, nil, nil, nil, 1, 1, nil, nil, 1, 50, 50, 50, 50, 20, nil, 50, 50, 2,
       nil, 50, 50, 50, 31, nil, 50, 24, nil, 50, nil, nil, nil, nil, nil, nil, nil, nil,
       nil, nil, nil, nil, nil, nil, nil, nil, nil] of UInt64?
    end

    it "parses correctly" do
      reports = subject.parse(filename)

      expect(reports.size).to eq 1
      expect(reports[0].to_h).to eq({
        :name          => "spec/fixtures/lcov/test.js",
        :coverage      => coverage,
        :source_digest => "6e7aea5aa7198489561a44359dc7e1a4",
      })
    end

    context "with base path" do
      let(filename) { "spec/fixtures/lcov/for-base-path-lcov" }
      let(base_path) { "spec/fixtures/lcov" }

      it "parses correctly" do
        reports = subject.parse(filename)

        expect(reports.size).to eq 1
        expect(reports[0].to_h).to eq({
          :name          => "spec/fixtures/lcov/test.js",
          :coverage      => coverage,
          :source_digest => "6e7aea5aa7198489561a44359dc7e1a4",
        })
      end
    end

    context "when referenced files from the same folder" do
      let(filename) { "spec/fixtures/lcov/test-current-folder.lcov" }

      it "parses correctly" do
        reports = subject.parse(filename)

        expect(reports.size).to eq 1
        expect(reports[0].to_h).to eq({
          :name          => "spec/fixtures/lcov/test.js",
          :coverage      => coverage,
          :source_digest => "6e7aea5aa7198489561a44359dc7e1a4",
        })
      end
    end

    context "when referenced files from the parent folder" do
      let(filename) { "spec/fixtures/lcov/coverage/test.lcov" }

      it "parses correctly" do
        reports = subject.parse(filename)

        expect(reports.size).to eq 1
        expect(reports[0].to_h).to eq({
          :name          => "spec/fixtures/lcov/test.js",
          :coverage      => coverage,
          :source_digest => "6e7aea5aa7198489561a44359dc7e1a4",
        })
      end
    end
  end
end
