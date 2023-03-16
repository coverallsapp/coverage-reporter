require "./options"

module CoverageReporter
  module CI
    module CircleCI
      extend self

      def options
        return unless ENV["CIRCLECI"]?

        Options.new(
          service_name: "circleci",
          service_number: ENV["CIRCLE_WORKFLOW_ID"]?,
          service_build_url: ENV["CIRCLE_BUILD_URL"]?,
          service_pull_request: ENV["CI_PULL_REQUEST"]? && ENV["CI_PULL_REQUEST"][/(\d+)$/, 1]?,
          service_job_number: ENV["CIRCLE_BUILD_NUM"]?,
          service_job_url: ENV["CIRCLE_BUILD_URL"]?,
          service_branch: ENV["CIRCLE_BRANCH"]?,
          commit_sha: ENV["CIRCLE_SHA1"]?,
        ).to_h
      end
    end
  end
end
