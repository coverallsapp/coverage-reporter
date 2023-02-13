require "./options"

module CoverageReporter
  module CI
    module Travis
      extend self

      def options
        return unless ENV["TRAVIS"]?

        pull_request = ENV["TRAVIS_PULL_REQUEST"]?

        Options.new(
          service_name: "travis-ci",
          service_number: ENV["TRAVIS_BUILD_NUMBER"]?,
          service_branch: ENV["TRAVIS_BRANCH"]?,
          service_job_id: ENV["TRAVIS_JOB_ID"]?,
          service_pull_request: pull_request == "false" ? nil : pull_request,
        ).to_h
      end
    end
  end
end
