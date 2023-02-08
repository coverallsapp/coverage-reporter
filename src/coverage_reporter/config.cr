require "./yaml_config.cr"

module CoverageReporter
  class Config
    DEFAULT_LOCATION = ".coveralls.yml"

    def initialize(@token : String?, job_flag : String?, @yaml : YamlConfig)
      @job_flag = !job_flag || job_flag.blank? ? nil : job_flag

      if !repo_token || repo_token == ""
        puts "🚨 Missing Repo Token. Set using `-r <token>` or `COVERALLS_REPO_TOKEN=<token>`"
        exit 1
      end
    end

    def get_config
      config = {} of Symbol => String | Nil
      config[:repo_token] = @token
      config[:job_flag] = @job_flag if @job_flag
      config[:flag_name] = ENV["COVERALLS_FLAG_NAME"] if ENV["COVERALLS_FLAG_NAME"]?
      config[:service_name] = ENV["COVERALLS_SERVICE_NAME"] if ENV["COVERALLS_SERVICE_NAME"]?

      config.merge!(get_ci_config)
      set_standard_service_params_for_generic_ci(config)

      config
    end

    private def get_ci_config
      get_service_params_for_travis(@yaml.config["service_name"]?.to_s || "") ||
        get_service_params_for_circleci ||
        get_service_params_for_semaphore ||
        get_service_params_for_jenkins ||
        get_service_params_for_appveyor ||
        get_service_params_for_tddium ||
        get_service_params_for_gitlab ||
        get_service_params_for_coveralls_local ||
        {} of Symbol => String | Nil
    end

    private def repo_token : String
      @token || ENV["COVERALLS_REPO_TOKEN"]? || @yaml.config["repo_token"].to_s || @yaml.config["repo_secret_token"].to_s
    end

    private def get_service_params_for_travis(service_name : String)
      return unless ENV["TRAVIS"]?

      config = {} of Symbol => String | Nil
      config[:service_job_id] = ENV["TRAVIS_JOB_ID"]?
      config[:service_pull_request] = ENV["TRAVIS_PULL_REQUEST"]? unless ENV["TRAVIS_PULL_REQUEST"]? == "false"
      config[:service_name] = service_name || "travis-ci"
      config[:service_branch] = ENV["TRAVIS_BRANCH"]?

      puts "🏢 Travis CI environment detected, configuring API post using:"
      puts "  ·service_branch: #{config[:service_branch]? || "none"} (TRAVIS_BRANCH)"
      puts "  ·service_job_number: #{config[:service_job_id]? || "none"} (TRAVIS_JOB_ID)"
      puts "  ·service_pull_request: #{config[:service_pull_request]? || "none"} (TRAVIS_PULL_REQUEST)"

      config
    end

    private def get_service_params_for_circleci
      return unless ENV["CIRCLECI"]?

      config = {} of Symbol => String | Nil
      config[:service_name] = "circleci"
      config[:service_number] = ENV["CIRCLE_WORKFLOW_ID"] if ENV.has_key?("CIRCLE_WORKFLOW_ID")
      config[:service_pull_request] = (ENV["CI_PULL_REQUEST"]? || "")[/(\d+)$/, 1] if ENV.has_key?("CI_PULL_REQUEST")
      config[:service_job_number] = ENV["CIRCLE_BUILD_NUM"]? if ENV.has_key?("CIRCLE_BUILD_NUM")
      config[:service_branch] = ENV["CIRCLE_BRANCH"]? if ENV.has_key?("CIRCLE_BRANCH")

      puts "🏢 Circle CI environment detected, configuring API post using:"
      puts "  ·service_branch: #{config[:service_branch]? || "none"} (CIRCLE_BRANCH)"
      puts "  ·service_job_number: #{config[:service_job_number]? || "none"} (CIRCLE_BUILD_NUM)"
      puts "  ·service_number: #{config[:service_number]? || "none"} (CIRCLE_WORKFLOW_ID)"
      puts "  ·service_pull_request: #{config[:service_pull_request]? || "none"} (CI_PULL_REQUEST)"

      config
    end

    private def get_service_params_for_semaphore
      return unless ENV["SEMAPHORE"]?

      {
        :service_name         => "semaphore",
        :service_number       => ENV["SEMAPHORE_BUILD_NUMBER"]?,
        :service_pull_request => ENV["PULL_RE,QUEST_NUMBER"]?,
      }
    end

    private def get_service_params_for_jenkins
      return unless ENV["JENKINS_URL"]? || ENV["JENKINS_HOME"]?

      {
        :service_name         => "jenkins",
        :service_number       => ENV["BUILD_NUMBER"]?,
        :service_branch       => ENV["BRANH_NAME"]?,
        :service_pull_request => ENV["ghprbPullId"]?,
      }
    end

    private def get_service_params_for_appveyor
      return unless ENV["APPVEYOR"]?

      {
        :service_name      => "appveyor",
        :service_number    => ENV["APPVEYOR_BUILD_VERSION"]?,
        :service_branch    => ENV["APPVEYOR_REPO_BRANCH"]?,
        :commit_sha        => ENV["APPVEYOR_REPO_COMMIT"]?,
        :service_build_url => "https://ci.appveyor.com/project/%s/build/%s" % [ENV["APPVEYOR_REPO_NAME"]?, ENV["APPVEYOR_BUILD_VERSION"]?],
      }
    end

    private def get_service_params_for_tddium
      return unless ENV["TDDIUM"]?

      {
        :service_name         => "tddium",
        :service_number       => ENV["TDDIUM_SESSION_ID"]?,
        :service_job_id       => ENV["TDDIUM_TID"]?,
        :service_pull_request => ENV["TDDIUM_PR_ID"]?,
        :service_branch       => ENV["TDDIUM_CURRENT_BRANCH"]?,
        :service_build_url    => "https://ci.solanolabs.com/reports/#{ENV["TDDIUM_SESSION_ID"]?}",
      }
    end

    private def get_service_params_for_gitlab
      return unless ENV["GITLAB_CI"]?

      {
        :service_name       => "gitlab-ci",
        :service_job_number => ENV["CI_BUILD_NAME"]?,
        :service_job_id     => ENV["CI_BUILD_ID"]?,
        :service_branch     => ENV["CI_BUILD_REF_NAME"]?,
        :commit_sha         => ENV["CI_BUILD_REF"]?,
      }
    end

    private def get_service_params_for_coveralls_local
      return unless ENV["COVERALLS_RUN_LOCALLY"]?

      {
        :service_job_id     => nil,
        :service_name       => "coveralls-universal",
        :service_event_type => "manual",
      }
    end

    private def set_standard_service_params_for_generic_ci(config)
      config[:service_name] ||= ENV["CI_NAME"]?
      config[:service_number] ||= ENV["CI_BUILD_NUMBER"]?
      config[:service_job_id] ||= ENV["CI_JOB_ID"]?
      config[:service_build_url] ||= ENV["CI_BUILD_URL"]?
      config[:service_branch] ||= ENV["CI_BRANCH"]?
      config[:service_pull_request] ||= (ENV["CI_PULL_REQUEST"]? || "")[/(\d+)$/, 1]?
    end
  end
end
