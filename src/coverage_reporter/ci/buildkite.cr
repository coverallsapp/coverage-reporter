require "./params"

module CoverageReporter
  module CI
    module Buildkite
      extend self

      def params
        return unless ENV["BUILDKITE"]?

        Params.new(
          service_name: "buildkite",
          service_job_number: ENV["BUILDKITE_BUILD_NUMBER"]?,
          service_job_id: ENV["BUILDKITE_BUILD_ID"]?,
          service_pull_request: ENV["BUILDKITE_PULL_REQUEST"]?,
          service_branch: ENV["BUILDKITE_BRANCH"]?,
          commit_sha: ENV["BUILDKITE_COMMIT"]?,
        ).to_h
      end
    end
  end
end
