require "./options"

module CoverageReporter
  module CI
    module Drone
      extend self

      def options
        return unless ENV["DRONE"]?

        Options.new(
          service_name: "drone",
          service_job_id: ENV["DRONE_BUILD_NUMBER"]?,
          service_pull_request: ENV["DRONE_PULL_REQUEST"]?,
          service_branch: ENV["DRONE_BRANCH"]?,
          commit_sha: ENV["DRONE_COMMIT"]?,
        ).to_h
      end
    end
  end
end
