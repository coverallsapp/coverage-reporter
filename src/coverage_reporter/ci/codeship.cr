require "./options"

module CoverageReporter
  module CI
    module Codeship
      extend self

      def options
        return unless ENV["CI_NAME"]? == "codeship"

        Options.new(
          service_name: "codeship",
          service_job_id: ENV["CI_BUILD_NUMBER"]?,
          service_branch: ENV["CI_BRANCH"]?,
          commit_sha: ENV["CI_COMMIT_ID"]?,
        ).to_h
      end
    end
  end
end
