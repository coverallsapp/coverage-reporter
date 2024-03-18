require "./options"

module CoverageReporter
  module CI
    module Codefresh
      extend self

      def options
        return unless ENV["CF_BRANCH"]?

        Options.new(
          service_name: "Codefresh",
          service_job_id: ENV["CF_BUILD_ID"]?,
          service_pull_request: ENV["CF_PULL_REQUEST_NUMBER"]?,
          service_branch: ENV["CF_BRANCH"]?,
          commit_sha: ENV["CF_REVISION"]?,
        ).to_h
      end
    end
  end
end
