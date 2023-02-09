require "./params"

module CoverageReporter
  module CI
    module Jenkins
      extend self

      def params
        return unless ENV["JENKINS_URL"]? || ENV["JENKINS_HOME"]?

        Params.new(
          service_name: "jenkins",
          service_number: ENV["BUILD_NUMBER"]?,
          service_branch: ENV["BRANCH_NAME"]?,
          service_pull_request: ENV["ghprbPullId"]?,
        ).to_h
      end
    end
  end
end
