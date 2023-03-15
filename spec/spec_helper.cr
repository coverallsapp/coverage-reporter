require "../src/coverage_reporter"

require "webmock"
require "spectator"

Spectator.configure do |config|
  config.fail_blank
  config.randomize

  config.before_suite do
    ENV.clear
    CoverageReporter::Log.set(CoverageReporter::Log::Level::Error)
  end
end
