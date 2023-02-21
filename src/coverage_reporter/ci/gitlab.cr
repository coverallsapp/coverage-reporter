require "./options"

module CoverageReporter
  module CI
    module Gitlab
      extend self

      def options
        return unless ENV["GITLAB_CI"]?

        Options.new(
          service_name: "gitlab-ci",
          service_job_id: ENV["CI_JOB_NAME"]?,
          service_job_number: ENV["CI_JOB_ID"]?,
          service_branch: ENV["CI_COMMIT_REF_NAME"]?,
          service_build_url: ENV["CI_JOB_URL"]?,
          commit_sha: ENV["CI_COMMIT_SHA"]?,
        ).to_h
      end
    end
  end
end
