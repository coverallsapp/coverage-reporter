require "./options"

module CoverageReporter
  module CI
    module Tddium
      extend self

      TDDIUM_URL = "https://ci.solanolabs.com"

      def options
        return unless ENV["TDDIUM"]?

        Options.new(
          service_name: "tddium",
          service_number: ENV["TDDIUM_SESSION_ID"]?,
          service_job_id: ENV["TDDIUM_TID"]?,
          service_pull_request: ENV["TDDIUM_PR_ID"]?,
          service_branch: ENV["TDDIUM_CURRENT_BRANCH"]?,
          service_build_url: "#{TDDIUM_URL}/reports/#{ENV["TDDIUM_SESSION_ID"]?}",
        ).to_h
      end
    end
  end
end
