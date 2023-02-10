require "./params"

module CoverageReporter
  module CI
    module Codefresh
      extend self

      def params
        return unless ENV["CF_BRANCH"]?

        Params.new(
          service_name: "Codefresh",
          service_job_id: ENV["CF_BUILD_ID"]?,
          service_pull_request: ENV["CF_PULL_REQUEST_ID"]?,
          service_branch: ENV["CF_BRANCH"]?,
          commit_sha: ENV["CF_REVISION"]?,
        ).to_h
      end
    end
  end
end
