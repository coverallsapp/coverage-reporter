# NOTE: The test suite expects a local Python venv (`.venv/`) with `coverage.py` + `pytest`.
# Run via `make test` which auto-creates/maintains the venv.
require "../src/coverage_reporter"
require "./support/*"

require "webmock"
require "spectator"

Spectator.configure do |config|
  config.fail_blank
  config.randomize

  config.before_suite do
    CoverageReporter::Log.set(CoverageReporter::Log::Level::Suppress)
  end

  config.before_suite do
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

  config.after_suite do
    File.delete("spec/fixtures/python/.coverage")
  end
end
