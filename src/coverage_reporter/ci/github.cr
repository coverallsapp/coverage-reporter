require "./options"

module CoverageReporter
  module CI
    module Github
      extend self

      def options
        return unless ENV["GITHUB_ACTIONS"]?

        if ENV["GITHUB_SERVER_URL"]? && ENV["GITHUB_REPOSITORY"]? && ENV["GITHUB_RUN_ID"]?
          build_url = "#{ENV["GITHUB_SERVER_URL"]}/#{ENV["GITHUB_REPOSITORY"]}/actions/runs/#{ENV["GITHUB_RUN_ID"]}"
        end

        Options.new(
          service_name: "github",
          repo_name: ENV["GITHUB_REPOSITORY"]?,
          service_number: ENV["GITHUB_RUN_ID"]?,
          service_job_id: ENV["GITHUB_JOB"]?,
          service_branch: ENV["GITHUB_HEAD_REF"]?.presence || ENV["GITHUB_REF_NAME"]?.presence,
          service_build_url: build_url,
          commit_sha: ENV["GITHUB_SHA"]?.presence,
        ).to_h
      end
    end
  end
end
