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
end
