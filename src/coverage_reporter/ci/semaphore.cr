require "./options"

module CoverageReporter
  module CI
    module Semaphore
      extend self

      def options
        return unless ENV["SEMAPHORE"]?

        Options.new(
          service_name: "semaphore",
          service_number: ENV["SEMAPHORE_WORKFLOW_ID"]?,
          service_job_id: ENV["SEMAPHORE_JOB_ID"]?,
          service_branch: ENV["SEMAPHORE_GIT_WORKING_BRANCH"]?,
          service_pull_request: ENV["SEMAPHORE_GIT_PR_NUMBER"]?,
          commit_sha: ENV["SEMAPHORE_GIT_SHA"]?,
          service_build_url: "#{ENV["SEMAPHORE_ORGANIZATION_URL"]?}/workflows/#{ENV["SEMAPHORE_WORKFLOW_ID"]?}",
          service_job_url: "#{ENV["SEMAPHORE_ORGANIZATION_URL"]?}/jobs/#{ENV["SEMAPHORE_JOB_ID"]?}"
        ).to_h
      end
    end
  end
end
