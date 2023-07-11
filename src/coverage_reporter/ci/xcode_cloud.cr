require "./options"

module CoverageReporter
  module CI
    module XcodeCloud
      extend self

      def options
        return unless ENV["CI_XCODE_PROJECT"]?

        Options.new(
          service_name: "xcode-cloud",
          service_number: ENV["CI_BUILD_NUMBER"]?,
          commit_sha: ENV["CI_COMMIT"]?,
          service_branch: ENV["CI_PULL_REQUEST_SOURCE_BRANCH"]? || ENV["CI_BRANCH"]?,
          service_pull_request: ENV["CI_PULL_REQUEST_NUMBER"]?,
        ).to_h
      end
    end
  end
end
