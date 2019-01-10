require "./yaml_config.cr"

module CoverageReporter
  class Config
    DEFAULT_LOCATION = ".coveralls.yml"

    def initialize(repo_token : String | Nil, yaml_file : YamlConfig)
      @token = repo_token.blank? ? nil : repo_token
      @yaml = yaml_file
    end

    def get_config
      config = {} of Symbol => String | Nil
      config[:repo_token] = repo_token
      puts @token
      config[:flag_name] = ENV["COVERALLS_FLAG_NAME"] if ENV["COVERALLS_FLAG_NAME"]?
      config[:service_name] = ENV["COVERALLS_SERVICE_NAME"] if ENV["COVERALLS_SERVICE_NAME"]?

      config.merge!(get_ci_config)
      set_standard_service_params_for_generic_ci(config)

      config
    end

    private def get_ci_config

      get_service_params_for_travis(@yaml ? @yaml.config["service_name"].to_s : "") ||
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

      config
    end

    private def get_service_params_for_circleci
      return unless ENV["CIRCLECI"]?

      {
        :service_name => "circleci",
        :service_number =>  ENV["CIRCLE_WORKFLOW_ID"]?,
        :service_pull_request => (ENV["CI_PULL_REQUEST"]? || "")[/(\d+)$/,1],
        :service_job_number => ENV["CIRCLE_BUILD_NUM"]?,
      }
    end

    private def get_service_params_for_semaphore
      return unless ENV["SEMAPHORE"]?

      {
        :service_name => "semaphore",
        :service_number => ENV["SEMAPHORE_BUILD_NUMBER"]?,
        :service_pull_request => ENV["PULL_RE,QUEST_NUMBER"]?,
      }
    end

    private def get_service_params_for_jenkins
      return unless ENV["JENKINS_URL"]? || ENV["JENKINS_HOME"]?

      {
        :service_name => "jenkins",
        :service_number => ENV["BUILD_NUMBER"]?,
        :service_branch => ENV["BRANH_NAME"]?,
        :service_pull_request => ENV["ghprbPullId"]?,
      }
    end

    private def get_service_params_for_appveyor
      return unless ENV["APPVEYOR"]?

      {
        :service_name => "appveyor",
        :service_number => ENV["APPVEYOR_BUILD_VERSION"]?,
        :service_branch => ENV["APPVEYOR_REPO_BRANCH"]?,
        :commit_sha => ENV["APPVEYOR_REPO_COMMIT"]?,
        :service_build_url => "https://ci.appveyor.com/project/%s/build/%s" % [ENV["APPVEYOR_REPO_NAME"]?, ENV["APPVEYOR_BUILD_VERSION"]?],
      }
    end

    private def get_service_params_for_tddium
      return unless ENV["TDDIUM"]?

      {
        :service_name => "tddium",
        :service_number => ENV["TDDIUM_SESSION_ID"]?,
        :service_job_id => ENV["TDDIUM_TID"]?,
        :service_pull_request => ENV["TDDIUM_PR_ID"]?,
        :service_branch => ENV["TDDIUM_CURRENT_BRANCH"]?,
        :service_build_url => "https://ci.solanolabs.com/reports/#{ENV["TDDIUM_SESSION_ID"]?}",
      }
    end

    private def get_service_params_for_gitlab
      return unless ENV["GITLAB_CI"]?

      {
        :service_name => "gitlab-ci",
        :service_job_number => ENV["CI_BUILD_NAME"]?,
        :service_job_id => ENV["CI_BUILD_ID"]?,
        :service_branch => ENV["CI_BUILD_REF_NAME"]?,
        :commit_sha => ENV["CI_BUILD_REF"]?
      }
    end

    private def get_service_params_for_coveralls_local
      return unless ENV["COVERALLS_RUN_LOCALLY"]?

      {
        :service_job_id => nil,
        :service_name => "coveralls-universal",
        :service_event_type => "manual",
      }
    end

    private def set_standard_service_params_for_generic_ci(config)

      config[:service_name] ||= ENV["CI_NAME"]?
      config[:service_number] ||= ENV["CI_BUILD_NUMBER"]?
      config[:service_job_id] ||= ENV["CI_JOB_ID"]?
      config[:service_build_url] ||= ENV["CI_BUILD_URL"]?
      config[:service_branch] ||= ENV["CI_BRANCH"]?
      #config[:service_pull_request] ||= (ENV["CI_PULL_REQUEST"]? || "")[/(\d+)$/,1]
    end

  end
end
