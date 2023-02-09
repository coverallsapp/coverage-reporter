require "../spec_helper"

Spectator.describe CoverageReporter::Config do
  subject { described_class.new(repo_token: repo_token, path: path, job_flag: job_flag) }

  describe ".new" do
    let(repo_token) { nil }
    let(path) { "" }
    let(job_flag) { nil }

    context "without repo_token" do
      it "raises an exception" do
        expect { subject }.to raise_error(CoverageReporter::Config::MissingTokenException)
      end
    end

    context "with empty repo_token" do
      let(repo_token) { "" }

      it "raises an exception" do
        expect { subject }.to raise_error(CoverageReporter::Config::MissingTokenException)
      end
    end

    context "with repo_token" do
      let(repo_token) { "token" }

      it "doesn't raise an exception" do
        expect { subject }.not_to raise_error
      end
    end

    context "without repo_token in YAML config" do
      let(path) { "spec/fixtures/configs/without-token.yml" }

      it "raises an exception" do
        expect { subject }.to raise_error(CoverageReporter::Config::MissingTokenException)
      end
    end

    context "with repo_token in YAML config" do
      let(path) { "spec/fixtures/configs/with-token.yml" }

      it "doesn't raise an exception" do
        expect { subject }.not_to raise_error
      end
    end

    context "with repo_token_secret in YAML config" do
      let(path) { "spec/fixtures/configs/with-secret-token.yml" }

      it "doesn't raise an exception" do
        expect { subject }.not_to raise_error
      end
    end

    context "with ENV preset" do
      before do
        ENV["COVERALLS_REPO_TOKEN"] = "env-token"
      end

      it "doesn't raise an exception" do
        expect { subject }.not_to raise_error
      end
    end
  end

  describe "#to_h" do
    subject do
      described_class.new(
        repo_token: "repo_token",
        path: "",
      ).to_h
    end

    context "for Appveyor CI" do
      before_all do
        ENV["APPVEYOR"] = "1"
        ENV["APPVEYOR_BUILD_VERSION"] = "123"
        ENV["APPVEYOR_REPO_BRANCH"] = "appveyor-repo-branch"
        ENV["APPVEYOR_REPO_COMMIT"] = "appveyor-commit-sha"
        ENV["APPVEYOR_REPO_NAME"] = "appveyor-repo-name"
      end

      after_all { ENV.clear }

      it "gets info from ENV" do
        expect(subject).to eq({
          :repo_token        => "repo_token",
          :service_name      => "appveyor",
          :service_number    => "123",
          :service_branch    => "appveyor-repo-branch",
          :commit_sha        => "appveyor-commit-sha",
          :service_build_url => "https://ci.appveyor.com/project/appveyor-repo-name/build/123",
        })
      end
    end

    context "for Circle CI" do
      before_all do
        ENV["CIRCLECI"] = "1"
        ENV["CIRCLE_WORKFLOW_ID"] = "9"
        ENV["CI_PULL_REQUEST"] = "PR 987"
        ENV["CIRCLE_BUILD_NUM"] = "8"
        ENV["CIRCLE_BRANCH"] = "circle-branch"
      end

      after_all { ENV.clear }

      it "gets info from ENV" do
        expect(subject).to eq({
          :repo_token           => "repo_token",
          :service_name         => "circleci",
          :service_number       => "9",
          :service_pull_request => "987",
          :service_job_number   => "8",
          :service_branch       => "circle-branch",
        })
      end
    end

    context "for generic CI" do
      # Imagine we are on Circle
      before_all do
        ENV["CIRCLECI"] = "1"
        ENV["CIRCLE_WORKFLOW_ID"] = "circle-service-number"
        ENV["CI_PULL_REQUEST"] = "PR 123"
        ENV["CIRCLE_BRANCH"] = "circle-branch"
        ENV["CI_BRANCH"] = "ci-branch"
        ENV["CI_JOB_ID"] = "ci-job-id"
        ENV["CI_BUILD_URL"] = "ci-build-url"
      end

      after_all { ENV.clear }

      it "gets info from ENV" do
        expect(subject).to eq({
          :repo_token           => "repo_token",
          :service_name         => "circleci",
          :service_number       => "circle-service-number",
          :service_pull_request => "123",
          :service_branch       => "circle-branch",
          :service_job_id       => "ci-job-id",
          :service_build_url    => "ci-build-url",
        })
      end
    end

    context "for Gitlab CI" do
      before_all do
        ENV["GITLAB_CI"] = "1"
        ENV["CI_BUILD_NAME"] = "gitlab-job-number"
        ENV["CI_BUILD_ID"] = "gitlab-job-id"
        ENV["CI_BUILD_REF_NAME"] = "gitlab-branch"
        ENV["CI_BUILD_REF"] = "gitlab-commit-sha"
      end

      after_all { ENV.clear }

      it "gets info from ENV" do
        expect(subject).to eq({
          :repo_token         => "repo_token",
          :service_name       => "gitlab-ci",
          :service_job_number => "gitlab-job-number",
          :service_job_id     => "gitlab-job-id",
          :service_branch     => "gitlab-branch",
          :commit_sha         => "gitlab-commit-sha",
        })
      end
    end

    context "for Jenkins CI" do
      before_all do
        ENV["JENKINS_HOME"] = "defined"
        ENV["BUILD_NUMBER"] = "jenkins-number"
        ENV["BRANCH_NAME"] = "jenkins-branch"
        ENV["ghprbPullId"] = "jenkins-pr"
      end

      after_all { ENV.clear }

      it "gets info from ENV" do
        expect(subject).to eq({
          :repo_token           => "repo_token",
          :service_name         => "jenkins",
          :service_number       => "jenkins-number",
          :service_branch       => "jenkins-branch",
          :service_pull_request => "jenkins-pr",
        })
      end
    end

    context "for local CI" do
      before_all do
        ENV["COVERALLS_RUN_LOCALLY"] = "1"
      end

      after_all { ENV.clear }

      it "provides custom params" do
        expect(subject).to eq({
          :repo_token         => "repo_token",
          :service_name       => "coveralls-universal",
          :service_event_type => "manual",
        })
      end
    end

    context "for Semaphore CI" do
      before_all do
        ENV["SEMAPHORE"] = "1"
        ENV["SEMAPHORE_BUILD_NUMBER"] = "semaphore-build-number"
        ENV["PULL_REQUEST_NUMBER"] = "semaphore-pr"
      end

      after_all { ENV.clear }

      it "provides custom params" do
        expect(subject).to eq({
          :repo_token           => "repo_token",
          :service_name         => "semaphore",
          :service_number       => "semaphore-build-number",
          :service_pull_request => "semaphore-pr",
        })
      end
    end

    context "for Tddim CI" do
      before_all do
        ENV["TDDIUM"] = "1"
        ENV["TDDIUM_SESSION_ID"] = "tddium-number"
        ENV["TDDIUM_TID"] = "tddium-job-id"
        ENV["TDDIUM_PR_ID"] = "tddium-pr"
        ENV["TDDIUM_CURRENT_BRANCH"] = "tddium-branch"
      end

      after_all { ENV.clear }

      it "provides custom params" do
        expect(subject).to eq({
          :repo_token           => "repo_token",
          :service_name         => "tddium",
          :service_number       => "tddium-number",
          :service_job_id       => "tddium-job-id",
          :service_pull_request => "tddium-pr",
          :service_branch       => "tddium-branch",
          :service_build_url    => "https://ci.solanolabs.com/reports/tddium-number",
        })
      end
    end

    context "for Travis CI" do
      before_all do
        ENV["TRAVIS"] = "1"
        ENV["TRAVIS_PULL_REQUEST"] = "travis-pr"
        ENV["TRAVIS_BRANCH"] = "travis-branch"
        ENV["TRAVIS_JOB_ID"] = "travis-job-id"
      end

      after_all { ENV.clear }

      it "provides custom params" do
        expect(subject).to eq({
          :repo_token           => "repo_token",
          :service_name         => "travis-ci",
          :service_branch       => "travis-branch",
          :service_job_id       => "travis-job-id",
          :service_pull_request => "travis-pr",
        })
      end
    end
  end
end
