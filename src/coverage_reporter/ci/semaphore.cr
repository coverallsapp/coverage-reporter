require "./params"

module CoverageReporter
  module CI
    module Semaphore
      extend self

      def params
        return unless ENV["SEMAPHORE"]?

        Params.new(
          service_name: "semaphore",
          service_job_id: ENV["SEMAPHORE_BUILD_NUMBER"]?,
          service_pull_request: ENV["PULL_REQUEST_NUMBER"]?,
        ).to_h
      end
    end
  end
end
