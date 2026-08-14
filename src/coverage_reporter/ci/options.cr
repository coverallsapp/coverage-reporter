module CoverageReporter
  module CI
    # Coveralls API options that can be retrieved from CI environment variables.
    class Options
      def initialize(
        @service_branch : String? = nil,
        @service_build_url : String? = nil,
        @service_event_type : String? = nil,
        @service_job_id : String? = nil,
        @service_job_number : String? = nil,
        @service_job_url : String? = nil,
        @service_name : String? = nil,
        @service_number : String? = nil,
        @service_pull_request : String? = nil,
        @service_attempt : String? = nil,
        @commit_sha : String? = nil,
        @repo_name : String? = nil,
      ); end

      def to_h : Hash(Symbol, String)
        {
          :service_branch       => @service_branch,
          :service_build_url    => @service_build_url,
          :service_event_type   => @service_event_type,
          :service_job_id       => @service_job_id,
          :service_job_number   => @service_job_number,
          :service_job_url      => @service_job_url,
          :service_name         => @service_name,
          :service_number       => @service_number,
          :service_pull_request => @service_pull_request,
          :service_attempt      => @service_attempt,
          :commit_sha           => @commit_sha,
          :repo_name            => @repo_name,
        }.compact
      end
    end
  end
end
