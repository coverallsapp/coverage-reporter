require "./options"

module CoverageReporter
  module CI
    module Wercker
      extend self

      def options
        return unless ENV["WERCKER"]?

        Options.new(
          service_name: "wercker",
          service_job_id: ENV["WERCKER_BUILD_ID"]?,
          service_branch: ENV["WERCKER_GIT_BRANCH"]?,
          commit_sha: ENV["WERCKER_GIT_COMMIT"]?,
        ).to_h
      end
    end
  end
end
