require "./options"

module CoverageReporter
  module CI
    module Gitlab
      extend self

      def options
        return unless ENV["GITLAB_CI"]?

        Options.new(
          service_name: "gitlab-ci",
          service_number: ENV["CI_PIPELINE_IID"]?,
          service_build_url: ENV["CI_PIPELINE_URL"]? || ENV["CI_JOB_URL"]?,
          service_job_id: ENV["CI_JOB_NAME"]?,
          service_job_url: ENV["CI_JOB_URL"]?,
          service_pull_request: ENV["CI_MERGE_REQUEST_IID"]?,
          service_branch: ENV["CI_COMMIT_REF_NAME"]?,
          commit_sha: ENV["CI_COMMIT_SHA"]?,
        ).to_h
      end
    end
  end
end
