require "./params"

module CoverageReporter
  module CI
    module Travis
      extend self

      def params(service_name : String?)
        return unless ENV["TRAVIS"]?

        pull_request = ENV["TRAVIS_PULL_REQUEST"]?

        Params.new(
          service_name: service_name || "travis-ci",
          service_branch: ENV["TRAVIS_BRANCH"]?,
          service_job_id: ENV["TRAVIS_JOB_ID"]?,
          service_pull_request: pull_request == "false" ? nil : pull_request,
        ).to_h
      end
    end
  end
end
