require "../spec_helper"

Spectator.describe CoverageReporter::Parser do
  subject { described_class.new(coverage_files, coverage_format, base_path) }

  let(coverage_files) { nil }
  let(coverage_format) { nil }
  let(base_path) { nil }

  describe "#parse" do
    context "for exact file" do
      context "clover" do
        let(coverage_files) { ["spec/fixtures/clover/clover-unleash.xml"] }

        it "returns reports for one file" do
          reports = subject.parse

          expect(reports.size).to be > 0
        end
      end

      context "cobertura" do
        let(coverage_files) { ["spec/fixtures/cobertura/cobertura.xml"] }

        it "returns reports" do
          reports = subject.parse

          expect(reports.size).to be > 0
        end
      end

      context "jacoco" do
        let(coverage_files) { ["spec/fixtures/jacoco/jacoco-report.xml"] }

        it "returns reports" do
          reports = subject.parse

          expect(reports.size).to be > 0
        end
      end

      context "golang" do
        let(coverage_files) { ["spec/fixtures/golang/coverage.out"] }

        it "returns reports" do
          reports = subject.parse

          expect(reports.size).to be > 0
        end
      end

      context "python" do
        let(coverage_files) { ["spec/fixtures/python/.coverage"] }

        it "returns reports" do
          reports = subject.parse

          expect(reports.size).to be > 0
        end
      end

      context "coveralls" do
        let(coverage_files) { ["spec/fixtures/coveralls/coveralls.json"] }

        it "returns reports" do
          reports = subject.parse

          expect(reports.size).to be > 0
        end
      end

      context "lcov" do
        let(coverage_files) { ["spec/fixtures/lcov/test.lcov"] }

        it "returns reports for one file" do
          reports = subject.parse

          expect(reports.size).to be > 0
        end
      end

      context "simplecov" do
        let(coverage_files) { ["spec/fixtures/simplecov/with-only-lines.resultset.json"] }

        it "returns reports" do
          reports = subject.parse

          expect(reports.size).to be > 0
        end
      end

      context "gcov" do
        let(coverage_files) { ["spec/fixtures/gcov/main.c.gcov"] }

        it "returns reports" do
          reports = subject.parse

          expect(reports.size).to be > 0
        end
      end

      context "for non-existing file" do
        let(coverage_files) { ["spec/fixtures/oops/coverage"] }

        it "raises error" do
          expect { subject.parse }
            .to raise_error(CoverageReporter::Parser::NotFound)
        end
      end

      context "for an unknown file format" do
        let(coverage_files) { ["spec/fixtures/lcov/index.js"] }

        it "returns an empty report" do
          reports = subject.parse

          expect(reports.size).to eq 0
        end
      end

      context "when coverage format forced (lcov)" do
        let(coverage_files) { ["spec/fixtures/lcov/test.lcov"] }
        let(coverage_format) { "lcov" }

        it "returns report only for specified format" do
          reports = subject.parse

          expect(reports.size).to eq 2
        end

        context "when a file is specified" do
          let(coverage_files) { ["spec/fixtures/lcov/for-base-path.lcov"] }
          let(base_path) { "spec/fixtures/lcov" }

          it "returns report only for specified file" do
            reports = subject.parse

            expect(reports.size).to eq 2
          end
        end

        context "when another format file specified" do
          let(coverage_files) { ["spec/fixtures/gcov/main.c.gcov"] }

          it "returns empty report" do
            reports = subject.parse

            expect(reports.size).to eq 0
          end
        end
      end

      context "when coverage format forced (python)" do
        let(coverage_format) { "python" }

        context "when a file is specified and coverage is installed" do
          let(coverage_files) { ["spec/fixtures/python/.coverage"] }
          let(base_path) { "spec/fixtures/python" }

          it "returns report only for specified file" do
            reports = subject.parse

            expect(reports.map { |r| r.to_h[:name] }).to contain("spec/fixtures/python/src/boring_math.py")
          end
        end

        context "when a file is specified and coverage is not installed" do
          let(coverage_files) { ["spec/fixtures/python/.coverage"] }
          let(base_path) { "spec/fixtures/python" }

          it "raises error" do
            path = ENV["PATH"]
            ENV.delete("PATH")

            expect { subject.parse }.to raise_error(CoverageReporter::CoveragepyParser::ParserError)

            ENV["PATH"] = path
          end
        end
      end

      context "for unknown coverage format" do
        let(coverage_files) { ["spec/fixtures/lcov/test.lcov"] }
        let(coverage_format) { "unknown" }

        it "raises error" do
          expect { subject.parse }
            .to raise_error(CoverageReporter::Parser::InvalidCoverageFormat)
        end
      end
    end

    context "for all files" do
      context "when coveragepy is installed" do
        it "returns reports for all files" do
          reports = subject.parse

          expect(reports.size).to be > 2
        end
      end

      context "when coveragepy is not installed" do
        it "returns reports for all files (no error is raised)" do
          path = ENV["PATH"]
          ENV.delete("PATH")

          reports = subject.parse

          expect(reports.size).to be > 2

          ENV["PATH"] = path
        end
      end
    end
  end

  describe "#files" do
    context "when no coverage_format specified" do
      it "returns all possible files across all formats" do
        files = subject.files

        # Ignore CI artifacts from kcov
        files.reject! { |f| f.starts_with?("coverage/") }

        expect(files).to match_array [
          "spec/fixtures/lcov/coverage/test.lcov",
          "spec/fixtures/lcov/test.lcov",
          "spec/fixtures/lcov/test-current-folder.lcov",
          "spec/fixtures/lcov/empty.lcov",
          "spec/fixtures/lcov/for-base-path.lcov",
          "spec/fixtures/simplecov/.resultset.json",
          "spec/fixtures/clover/clover.xml",
          "spec/fixtures/cobertura/cobertura.xml",
          "spec/fixtures/cobertura/cobertura-coverage.xml",
          "spec/fixtures/jacoco/jacoco-oneline-report.xml",
          "spec/fixtures/jacoco/jacoco-report-multiple-packages.xml",
          "spec/fixtures/jacoco/jacoco-report.xml",
          "spec/fixtures/gcov/main.c.gcov",
          "spec/fixtures/python/.coverage",
          "spec/fixtures/coveralls/coveralls.json",
        ]
      end
    end

    context "when coverage_format specified" do
      let(coverage_format) { "cobertura" }

      it "only returns possible files for the specified format" do
        files = subject.files

        # Ignore CI artifacts from kcov
        files.reject! { |f| f.starts_with?("coverage/") }

        expect(files).to match_array [
          "spec/fixtures/cobertura/cobertura.xml",
          "spec/fixtures/cobertura/cobertura-coverage.xml",
        ]
      end
    end
  end
end
