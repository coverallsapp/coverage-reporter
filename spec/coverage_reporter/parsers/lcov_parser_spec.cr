require "../../spec_helper"

Spectator.describe CoverageReporter::LcovParser do
  subject { described_class.new(base_path) }

  let(base_path) { nil }

  describe "#globs" do
    it "finds all lcov files" do
      expect(Dir[subject.globs]).to contain(
        "spec/fixtures/lcov/empty.lcov",
        "spec/fixtures/lcov/test.lcov",
        "spec/fixtures/lcov/coverage/test.lcov",
        "spec/fixtures/lcov/test-current-folder.lcov",
      )
    end
  end

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
    let(digest) { "bbc3522fe6728f6e24bfe930a87ecc54" }
    let(coverage) do
      [1, nil, nil, 1, nil, nil, nil, nil, nil, 2, 2, nil, 18446744073709551615u64,
       nil, nil, nil, 2, 2, nil, 2, nil, 2, nil, nil, nil, 1, 1, nil, nil, nil,
       1, nil, nil, nil, 0, nil, nil, nil, 1] of UInt64?
    end
    let(branches) do
      [10, 0, 0, 1, 10, 0, 1, 1,
       10, 1, 0, 0, 10, 1, 1, 1,
       11, 2, 0, 1, 11, 2, 1, 1,
       20, 3, 0, 1, 20, 3, 1, 1] of UInt64
    end

    it "parses correctly" do
      reports = subject.parse(filename)

      expect(reports.size).to eq 2
      expect(reports[0].to_h).to eq({
        :name          => "spec/fixtures/lcov/index.js",
        :coverage      => [1, 1],
        :source_digest => "97afaf84480a9f3fbb13393085b1d49d",
      })
      expect(reports[1].to_h).to eq({
        :name          => "spec/fixtures/lcov/lib/run.js",
        :coverage      => coverage,
        :branches      => branches,
        :source_digest => digest,
      })
    end

    context "with base path" do
      let(filename) { "spec/fixtures/lcov/for-base-path.lcov" }
      let(base_path) { "spec/fixtures/lcov" }

      it "parses correctly" do
        reports = subject.parse(filename)

        expect(reports.size).to eq 2
        expect(reports[1].to_h).to eq({
          :name          => "spec/fixtures/lcov/lib/run.js",
          :coverage      => coverage,
          :branches      => branches,
          :source_digest => digest,
        })
      end
    end

    context "when referenced files from the same folder" do
      let(filename) { "spec/fixtures/lcov/test-current-folder.lcov" }

      it "parses correctly" do
        reports = subject.parse(filename)

        expect(reports.size).to eq 2
        expect(reports[1].to_h).to eq({
          :name          => "spec/fixtures/lcov/lib/run.js",
          :coverage      => coverage,
          :branches      => branches,
          :source_digest => digest,
        })
      end
    end

    context "when referenced files from the parent folder" do
      let(filename) { "spec/fixtures/lcov/coverage/test.lcov" }

      it "parses correctly" do
        reports = subject.parse(filename)

        expect(reports.size).to eq 2
        expect(reports[1].to_h).to eq({
          :name          => "spec/fixtures/lcov/lib/run.js",
          :coverage      => coverage,
          :branches      => branches,
          :source_digest => digest,
        })
      end
    end
  end
end
