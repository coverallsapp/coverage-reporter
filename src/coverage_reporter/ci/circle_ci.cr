require "./params"

module CoverageReporter
  module CI
    module CircleCI
      extend self

      def params
        return unless ENV["CIRCLECI"]?

        Params.new(
          service_name: "circleci",
          service_number: ENV["CIRCLE_WORKFLOW_ID"]?,
          service_pull_request: ENV["CI_PULL_REQUEST"]? && ENV["CI_PULL_REQUEST"][/(\d+)$/, 1]?,
          service_job_number: ENV["CIRCLE_BUILD_NUM"]?,
          service_branch: ENV["CIRCLE_BRANCH"]?,
        ).to_h
      end
    end
  end
end
