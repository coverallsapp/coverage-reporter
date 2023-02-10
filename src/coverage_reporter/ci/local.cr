require "./options"

module CoverageReporter
  module CI
    module Local
      extend self

      def options
        return unless ENV["COVERALLS_RUN_LOCALLY"]?

        Options.new(
          service_job_id: nil,
          service_name: "coveralls-universal",
          service_event_type: "manual",
        ).to_h
      end
    end
  end
end
