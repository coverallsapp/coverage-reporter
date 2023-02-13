require "./options"

module CoverageReporter
  module CI
    module Azure
      extend self

      def options
        return unless ENV["TF_BUILD"]?

        Options.new(
          service_name: "Azure Pipelines",
          service_job_id: ENV["BUILD_BUILDID"]?,
          service_pull_request: ENV["SYSTEM_PULLREQUEST_PULLREQUESTNUMBER"]?,
          service_branch: ENV["BUILD_SOURCEBRANCHNAME"]?,
          commit_sha: ENV["BUILD_SOURCEVERSION"]?,
        ).to_h
      end
    end
  end
end
