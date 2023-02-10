require "./params"

module CoverageReporter
  module CI
    module Surf
      extend self

      def params
        return unless ENV["SURF_SHA1"]?

        Params.new(
          service_name: "surf",
          service_branch: ENV["SURF_REF"]?,
          commit_sha: ENV["SURF_SHA1"]?,
        ).to_h
      end
    end
  end
end
