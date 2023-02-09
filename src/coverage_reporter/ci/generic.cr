require "./params"

module CoverageReporter
  module CI
    # Provides the params that can be used in any CI as a fallback
    # for CI-specific ENV params.
    module Generic
      extend self

      def params
        Params.new(
          service_name: ENV["CI_NAME"]?,
          service_number: ENV["CI_BUILD_NUMBER"]?,
          service_job_id: ENV["CI_JOB_ID"]?,
          service_build_url: ENV["CI_BUILD_URL"]?,
          service_branch: ENV["CI_BRANCH"]?,
          service_pull_request: ENV["CI_PULL_REQUEST"]? && ENV["CI_PULL_REQUEST"][/(\d+)$/, 1]?,
        ).to_h
      end
    end
  end
end
