require "./options"

module CoverageReporter
  module CI
    module Rwx
      extend self

      def options
        return unless ENV["RWX"]?

        Options.new(
          service_name: "rwx",
          repo_name: ENV["RWX_GIT_REPOSITORY_NAME"]?,
          service_number: ENV["RWX_RUN_ID"]?,
          service_job_id: ENV["RWX_TASK_ID"]?,
          service_branch: ENV["RWX_GIT_REF_NAME"]?,
          service_build_url: ENV["RWX_RUN_URL"]?,
          service_job_url: ENV["RWX_TASK_URL"]?,
          service_attempt: ENV["RWX_TASK_ATTEMPT_NUMBER"]?,
          commit_sha: ENV["RWX_GIT_COMMIT_SHA"]?,
        ).to_h
      end
    end
  end
end
