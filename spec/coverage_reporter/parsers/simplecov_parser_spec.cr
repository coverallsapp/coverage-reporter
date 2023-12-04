require "../../spec_helper"

Spectator.describe CoverageReporter::SimplecovParser do
  subject { described_class.new }

  describe "#globs" do
    it "finds all simplecov files" do
      expect(Dir[subject.globs]).to contain(
        Path.new("spec", "fixtures", "simplecov", ".resultset.json").to_s,
      )
    end
  end

  describe "#matches?" do
    it "matches correct filenames" do
      expect(subject.matches?(".resultset.jsonb")).to eq false
      expect(subject.matches?(".resultset.json")).to eq true
      expect(subject.matches?("path/to/.resultset.json")).to eq true
      expect(subject.matches?("path/to/file.resultset.json")).to eq true
    end
  end

  describe "#parse" do
    let(filename) { "spec/fixtures/simplecov/.resultset.json" }

    it "parses correctly" do
      reports = subject.parse(filename)
      expect(reports.size).to eq 5
      expect(reports[0].to_h).to eq({
        :name     => "Users/nickmerwin/www/coveralls-ruby/lib/coveralls.rb",
        :branches => [] of UInt64,
        :coverage => [
          1, 1, 1, 1, 1, nil, 1, 1, nil, 1, 1, nil, nil, nil, 1, nil, 1, 3, 3, nil, nil,
          1, 1, 1, 1, 1, nil, nil, 1, 1, 1, 1, nil, nil, 1, nil, 4, 4, 3, nil, 1, 1, 1,
          nil, nil, nil, nil, nil, 4, 3, 3, nil, 1, nil, nil, nil, nil, 1, 4, 4, nil, 4,
          2, 2, 1, nil, 1, nil, 2, 1, 1, nil, 1, 1, nil, nil, nil, nil, 1, nil, 4, 2, 2,
          nil, nil, 2, 2, nil, nil, 2, nil, nil, 1, 6, 6, nil, nil, 1, 1, nil, nil,
        ],
      })
    end

    context "with branches" do
      let(filename) { "spec/fixtures/simplecov/with-branches.resultset.json" }

      it "parses correctly" do
        reports = subject.parse(filename)
        expect(reports.size).to eq 1
        expect(reports[0].to_h).to eq({
          :name     => "home/user/app/models/user.rb",
          :branches => [12, 0, 1, 1, 12, 0, 2, 0],
          :coverage => [nil, 1, 1, 0, nil, nil, 1, 0, nil, nil, 1, 0, 0, nil, nil, nil],
        })
      end
    end

    context "with only lines" do
      let(filename) { "spec/fixtures/simplecov/with-only-lines.resultset.json" }

      it "parses correctly" do
        reports = subject.parse(filename)
        expect(reports.size).to eq 1
        expect(reports[0].to_h).to eq({
          :name     => "home/user/app/models/user.rb",
          :branches => [] of UInt64,
          :coverage => [nil, 1, 1, 0, nil, nil, 1, 0, nil, nil, 1, 0, 0, nil, nil, nil],
        })
      end
    end
  end
end
