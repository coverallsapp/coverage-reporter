require "./options"

module CoverageReporter
  module CI
    module Jenkins
      extend self

      def options
        return unless ENV["JENKINS_URL"]? || ENV["JENKINS_HOME"]?

        Options.new(
          service_name: "jenkins",
          service_number: ENV["BUILD_NUMBER"]?,
          service_job_id: ENV["BUILD_ID"]?,
          service_branch: ENV["BRANCH_NAME"]?,
          service_pull_request: ENV["CHANGE_ID"]? || ENV["ghprbPullId"]?,
        ).to_h
      end
    end
  end
end
