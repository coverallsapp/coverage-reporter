require "./options"

module CoverageReporter
  module CI
    module Appveyor
      extend self

      APPVEYOR_URL = "https://ci.appveyor.com"

      def options
        return unless ENV["APPVEYOR"]?

        Options.new(
          service_name: "appveyor",
          service_number: ENV["APPVEYOR_BUILD_VERSION"]?,
          service_job_number: ENV["APPVEYOR_BUILD_NUMBER"]?,
          service_job_id: ENV["APPVEYOR_BUILD_ID"]?,
          service_branch: ENV["APPVEYOR_REPO_BRANCH"]?,
          commit_sha: ENV["APPVEYOR_REPO_COMMIT"]?,
          service_build_url: "#{APPVEYOR_URL}/project/#{ENV["APPVEYOR_REPO_NAME"]?}/build/#{ENV["APPVEYOR_BUILD_VERSION"]?}",
        ).to_h
      end
    end
  end
end
