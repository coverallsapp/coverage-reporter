require "./params"

module CoverageReporter
  module CI
    module Drone
      extend self

      def params
        return unless ENV["DRONE"]?

        Params.new(
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
