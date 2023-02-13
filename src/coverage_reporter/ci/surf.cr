require "./options"

module CoverageReporter
  module CI
    module Surf
      extend self

      def options
        return unless ENV["SURF_SHA1"]?

        Options.new(
          service_name: "surf",
          service_branch: ENV["SURF_REF"]?,
          commit_sha: ENV["SURF_SHA1"]?,
        ).to_h
      end
    end
  end
end
