require "./options"

module CoverageReporter
  module CI
    # Woodpecker CI: https://woodpecker-ci.org/docs/usage/environment
    module Woodpecker
      extend self

      def options
        return unless ENV["CI"]? == "woodpecker"

        Options.new(
          service_name: "woodpecker",
          repo_name: ENV["CI_REPO"]?.presence,
          service_number: ENV["CI_PIPELINE_NUMBER"]?.presence,
          service_build_url: ENV["CI_PIPELINE_URL"]?.presence,
          service_job_id: ENV["CI_WORKFLOW_NAME"]?.presence,
          service_job_number: ENV["CI_WORKFLOW_NUMBER"]?.presence,
          service_job_url: ENV["CI_STEP_URL"]?.presence,
          service_pull_request: ENV["CI_COMMIT_PULL_REQUEST"]?.presence,
          # On pull request events CI_COMMIT_BRANCH is the target branch.
          service_branch: ENV["CI_COMMIT_SOURCE_BRANCH"]?.presence || ENV["CI_COMMIT_BRANCH"]?.presence,
          commit_sha: ENV["CI_COMMIT_SHA"]?.presence,
        ).to_h
      end
    end
  end
end
