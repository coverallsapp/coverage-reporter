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
          service_branch: ENV["BRANCH_NAME"]? || ENV["CHANGE_BRANCH"]?,
          service_build_url: ENV["BUILD_URL"]?,
          service_job_url: ENV["BUILD_URL"]?,
          service_pull_request: ENV["CHANGE_ID"]? || ENV["ghprbPullId"]?,
        ).to_h
      end
    end
  end
end
