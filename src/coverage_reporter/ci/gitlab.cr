require "./params"

module CoverageReporter
  module CI
    module Gitlab
      extend self

      def params
        return unless ENV["GITLAB_CI"]?

        Params.new(
          service_name: "gitlab-ci",
          service_job_number: ENV["CI_BUILD_NAME"]?,
          service_job_id: ENV["CI_BUILD_ID"]?,
          service_branch: ENV["CI_BUILD_REF_NAME"]?,
          commit_sha: ENV["CI_BUILD_REF"]?,
        ).to_h
      end
    end
  end
end
