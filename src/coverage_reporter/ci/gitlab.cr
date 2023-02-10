require "./params"

module CoverageReporter
  module CI
    module Gitlab
      extend self

      def params
        return unless ENV["GITLAB_CI"]?

        Params.new(
          service_name: "gitlab-ci",
          service_job_number: ENV["CI_JOB_ID"]? || ENV["CI_BUILD_NAME"]?,
          service_job_id: ENV["CI_JOB_NAME"]? || ENV["CI_BUILD_ID"]?,
          service_branch: ENV["CI_COMMIT_REF_NAME"]?,
          service_build_url: ENV["CI_JOB_URL"]?,
          commit_sha: ENV["CI_COMMIT_SHA"]?,
        ).to_h
      end
    end
  end
end
