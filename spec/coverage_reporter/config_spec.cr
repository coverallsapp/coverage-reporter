require "../spec_helper"

Spectator.describe CoverageReporter::Config do
  subject do
    described_class.new(
      repo_token: repo_token,
      path: path,
      flag_name: job_flag_name,
      compare_ref: compare_ref,
      compare_sha: compare_sha,
    )
  end

  before_each { ENV.clear }
  after_each { ENV.clear }

  let(repo_token) { nil }
  let(path) { "" }
  let(job_flag_name) { nil }
  let(compare_ref) { nil }
  let(compare_sha) { nil }

  describe ".new" do
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
      before_each do
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
        repo_token: repo_token,
        path: path,
        flag_name: job_flag_name,
        compare_ref: compare_ref,
        compare_sha: compare_sha,
      ).to_h
    end

    let(repo_token) { "repo_token" }

    context "with compare_ref" do
      let(compare_ref) { "some-branch" }
      let(compare_sha) { "some-commit-sha" }

      it "adds compare_ref option" do
        expect(subject).to eq({
          :repo_token  => repo_token,
          :compare_ref => compare_ref,
          :compare_sha => compare_sha,
        })
      end
    end

    context "for Appveyor CI" do
      before_each do
        ENV["APPVEYOR"] = "1"
        ENV["APPVEYOR_BUILD_VERSION"] = "123"
        ENV["APPVEYOR_REPO_BRANCH"] = "appveyor-repo-branch"
        ENV["APPVEYOR_REPO_COMMIT"] = "appveyor-commit-sha"
        ENV["APPVEYOR_REPO_NAME"] = "appveyor-repo-name"
      end

      it "gets info from ENV" do
        expect(subject).to eq({
          :repo_token        => repo_token,
          :service_name      => "appveyor",
          :service_number    => "123",
          :service_branch    => "appveyor-repo-branch",
          :commit_sha        => "appveyor-commit-sha",
          :service_build_url => "https://ci.appveyor.com/project/appveyor-repo-name/build/123",
        })
      end
    end

    context "for Circle CI" do
      before_each do
        ENV["CIRCLECI"] = "1"
        ENV["CIRCLE_WORKFLOW_ID"] = "9"
        ENV["CI_PULL_REQUEST"] = "PR 987"
        ENV["CIRCLE_BUILD_NUM"] = "8"
        ENV["CIRCLE_BRANCH"] = "circle-branch"
        ENV["CIRCLE_BUILD_URL"] = "build-url"
      end

      it "gets info from ENV" do
        expect(subject).to eq({
          :repo_token           => repo_token,
          :service_name         => "circleci",
          :service_number       => "9",
          :service_build_url    => "build-url",
          :service_pull_request => "987",
          :service_job_number   => "8",
          :service_job_url      => "build-url",
          :service_branch       => "circle-branch",
        })
      end
    end

    context "for generic CI" do
      # Imagine we are on Circle
      before_each do
        ENV["CIRCLECI"] = "1"
        ENV["CIRCLE_WORKFLOW_ID"] = "circle-service-number"
        ENV["CI_PULL_REQUEST"] = "PR 123"
        ENV["CIRCLE_BRANCH"] = "circle-branch"
        ENV["CI_BRANCH"] = "ci-branch"
        ENV["CI_JOB_ID"] = "ci-job-id"
        ENV["CI_BUILD_URL"] = "ci-build-url"
      end

      it "gets info from ENV" do
        expect(subject).to eq({
          :repo_token           => repo_token,
          :service_name         => "circleci",
          :service_number       => "circle-service-number",
          :service_pull_request => "123",
          :service_branch       => "circle-branch",
          :service_job_id       => "ci-job-id",
          :service_build_url    => "ci-build-url",
        })
      end
    end

    context "for Github Actions" do
      before_each do
        ENV["GITHUB_ACTIONS"] = "true"
        ENV["GITHUB_SERVER_URL"] = "https://github.com"
        ENV["GITHUB_REPOSITORY"] = "owner/repo"
        ENV["GITHUB_RUN_ID"] = "12345"
        ENV["GITHUB_JOB"] = "test"
        ENV["GITHUB_REF_NAME"] = "main"
        ENV["GITHUB_HEAD_REF"] = "fix/bug"
        ENV["GITHUB_SHA"] = "github-commit-sha"
        ENV["GITHUB_REF"] = "refs/pull/123"
        ENV["GITHUB_RUN_ATTEMPT"] = "3"
      end

      it "gets info from ENV" do
        expect(subject).to eq({
          :repo_token           => repo_token,
          :repo_name            => "owner/repo",
          :service_attempt      => "3",
          :service_name         => "github",
          :service_number       => "12345",
          :service_job_id       => "test",
          :service_branch       => "fix/bug",
          :service_build_url    => "https://github.com/owner/repo/actions/runs/12345",
          :service_job_url      => "https://github.com/owner/repo/actions/runs/12345",
          :service_pull_request => "123",
          :commit_sha           => "github-commit-sha",
        })
      end
    end

    context "for Gitlab CI" do
      before_each do
        ENV["GITLAB_CI"] = "1"
        ENV["CI_JOB_NAME"] = "gitlab-job-id"
        ENV["CI_PIPELINE_IID"] = "123"
        ENV["CI_COMMIT_REF_NAME"] = "gitlab-branch"
        ENV["CI_COMMIT_SHA"] = "gitlab-commit-sha"
        ENV["CI_JOB_URL"] = "https://gitlab.com/job-url"
        ENV["CI_PIPELINE_URL"] = "https://gitlab.com/pipeline-url"
        ENV["CI_MERGE_REQUEST_IID"] = "3"
      end

      it "gets info from ENV" do
        expect(subject).to eq({
          :repo_token           => repo_token,
          :service_name         => "gitlab-ci",
          :service_number       => "123",
          :service_build_url    => "https://gitlab.com/pipeline-url",
          :service_job_id       => "gitlab-job-id",
          :service_job_url      => "https://gitlab.com/job-url",
          :service_pull_request => "3",
          :service_branch       => "gitlab-branch",
          :commit_sha           => "gitlab-commit-sha",
        })
      end
    end

    context "for Jenkins CI" do
      before_each do
        ENV["JENKINS_HOME"] = "defined"
        ENV["BUILD_ID"] = "jenkins-id"
        ENV["BUILD_NUMBER"] = "jenkins-number"
        ENV["BRANCH_NAME"] = "jenkins-branch"
        ENV["ghprbPullId"] = "jenkins-pr"
      end

      it "gets info from ENV" do
        expect(subject).to eq({
          :repo_token           => repo_token,
          :service_name         => "jenkins",
          :service_number       => "jenkins-number",
          :service_job_id       => "jenkins-id",
          :service_branch       => "jenkins-branch",
          :service_pull_request => "jenkins-pr",
        })
      end
    end

    context "for local CI" do
      before_each do
        ENV["COVERALLS_RUN_LOCALLY"] = "1"
      end

      it "provides custom options" do
        expect(subject).to eq({
          :repo_token         => repo_token,
          :service_name       => "coveralls-universal",
          :service_event_type => "manual",
        })
      end
    end

    context "for Semaphore CI" do
      before_each do
        ENV["SEMAPHORE"] = "1"
        ENV["SEMAPHORE_WORKFLOW_ID"] = "semaphore-workflow-id"
        ENV["SEMAPHORE_GIT_WORKING_BRANCH"] = "semaphore-branch"
        ENV["SEMAPHORE_GIT_PR_NUMBER"] = "semaphore-pr"
        ENV["SEMAPHORE_GIT_SHA"] = "semaphore-commit-sha"
        ENV["SEMAPHORE_ORGANIZATION_URL"] = "https://myorg.semaphoreci.com"
        ENV["SEMAPHORE_JOB_ID"] = "semaphore-job-id"
      end

      it "provides custom options" do
        expect(subject).to eq({
          :repo_token           => repo_token,
          :service_name         => "semaphore",
          :service_number       => "semaphore-workflow-id",
          :service_job_id       => "semaphore-job-id",
          :service_pull_request => "semaphore-pr",
          :service_branch       => "semaphore-branch",
          :commit_sha           => "semaphore-commit-sha",
          :service_build_url    => "https://myorg.semaphoreci.com/workflows/semaphore-workflow-id",
          :service_job_url      => "https://myorg.semaphoreci.com/jobs/semaphore-job-id",
        })
      end
    end

    context "for Tddim CI" do
      before_each do
        ENV["TDDIUM"] = "1"
        ENV["TDDIUM_SESSION_ID"] = "tddium-number"
        ENV["TDDIUM_TID"] = "tddium-job-id"
        ENV["TDDIUM_PR_ID"] = "tddium-pr"
        ENV["TDDIUM_CURRENT_BRANCH"] = "tddium-branch"
      end

      it "provides custom options" do
        expect(subject).to eq({
          :repo_token           => repo_token,
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
      before_each do
        ENV["TRAVIS"] = "1"
        ENV["TRAVIS_PULL_REQUEST"] = "travis-pr"
        ENV["TRAVIS_BRANCH"] = "travis-branch"
        ENV["TRAVIS_JOB_NUMBER"] = "travis-job-id"
        ENV["TRAVIS_BUILD_NUMBER"] = "travis-build-number"
      end

      it "provides custom options" do
        expect(subject).to eq({
          :repo_token           => repo_token,
          :service_name         => "travis-ci",
          :service_number       => "travis-build-number",
          :service_branch       => "travis-branch",
          :service_job_id       => "travis-job-id",
          :service_pull_request => "travis-pr",
        })
      end

      context "for custom ENVs" do
        before_each do
          ENV["COVERALLS_SERVICE_NAME"] = "custom-ci"
          ENV["COVERALLS_SERVICE_NUMBER"] = "custom-build-number"
          ENV["COVERALLS_SERVICE_JOB_ID"] = "custom-job-id"
          ENV["COVERALLS_GIT_BRANCH"] = "custom-git-branch"
          ENV["COVERALLS_GIT_COMMIT"] = "custom-sha"
        end

        it "provides custom options" do
          expect(subject).to eq({
            :repo_token           => repo_token,
            :service_name         => "custom-ci",
            :service_number       => "custom-build-number",
            :service_branch       => "custom-git-branch",
            :service_job_id       => "custom-job-id",
            :service_pull_request => "travis-pr",
            :commit_sha           => "custom-sha",
          })
        end
      end
    end

    context "for Azure" do
      before_each do
        ENV["TF_BUILD"] = "1"
        ENV["BUILD_BUILDID"] = "azure-build-id"
        ENV["SYSTEM_PULLREQUEST_PULLREQUESTNUMBER"] = "azure-pull-request"
        ENV["BUILD_SOURCEBRANCHNAME"] = "azure-branch"
        ENV["BUILD_SOURCEVERSION"] = "azure-commit"
      end

      it "provides custom options" do
        expect(subject).to eq({
          :repo_token           => repo_token,
          :service_name         => "Azure Pipelines",
          :service_branch       => "azure-branch",
          :service_job_id       => "azure-build-id",
          :service_pull_request => "azure-pull-request",
          :commit_sha           => "azure-commit",
        })
      end
    end

    context "for Buildkite" do
      before_each do
        ENV["BUILDKITE"] = "1"
        ENV["BUILDKITE_BUILD_NUMBER"] = "bk-job-number"
        ENV["BUILDKITE_BUILD_ID"] = "bk-job-id"
        ENV["BUILDKITE_PULL_REQUEST"] = "bk-pr"
        ENV["BUILDKITE_BRANCH"] = "bk-branch"
        ENV["BUILDKITE_COMMIT"] = "bk-commit"
      end

      it "provides custom options" do
        expect(subject).to eq({
          :repo_token           => repo_token,
          :service_name         => "buildkite",
          :service_branch       => "bk-branch",
          :service_job_number   => "bk-job-number",
          :service_job_id       => "bk-job-id",
          :service_pull_request => "bk-pr",
          :commit_sha           => "bk-commit",
        })
      end
    end

    context "for Codefresh" do
      before_each do
        ENV["CF_BRANCH"] = "cf-branch"
        ENV["CF_BUILD_ID"] = "cf-job-id"
        ENV["CF_PULL_REQUEST_ID"] = "cf-pr"
        ENV["CF_BRANCH"] = "cf-branch"
        ENV["CF_REVISION"] = "cf-commit"
      end

      it "provides custom options" do
        expect(subject).to eq({
          :repo_token           => repo_token,
          :service_name         => "Codefresh",
          :service_branch       => "cf-branch",
          :service_job_id       => "cf-job-id",
          :service_pull_request => "cf-pr",
          :commit_sha           => "cf-commit",
        })
      end
    end

    context "for Codeship" do
      before_each do
        ENV["CI_NAME"] = "codeship"
        ENV["CI_BUILD_NUMBER"] = "codeship-job-id"
        ENV["CI_BRANCH"] = "codeship-branch"
        ENV["CI_COMMIT_ID"] = "codeship-commit"
      end

      it "provides custom options" do
        expect(subject).to eq({
          :repo_token     => repo_token,
          :service_name   => "codeship",
          :service_branch => "codeship-branch",
          :service_number => "codeship-job-id",
          :service_job_id => "codeship-job-id",
          :commit_sha     => "codeship-commit",
        })
      end
    end

    context "for Drone" do
      before_each do
        ENV["DRONE"] = "drone"
        ENV["DRONE_BUILD_NUMBER"] = "drone-job-id"
        ENV["DRONE_PULL_REQUEST"] = "drone-pr"
        ENV["DRONE_BRANCH"] = "drone-branch"
        ENV["DRONE_COMMIT"] = "drone-commit"
      end

      it "provides custom options" do
        expect(subject).to eq({
          :repo_token           => repo_token,
          :service_name         => "drone",
          :service_branch       => "drone-branch",
          :service_job_id       => "drone-job-id",
          :service_pull_request => "drone-pr",
          :commit_sha           => "drone-commit",
        })
      end
    end

    context "for Surf" do
      before_each do
        ENV["SURF_SHA1"] = "surf-commit"
        ENV["SURF_REF"] = "surf-branch"
      end

      it "provides custom options" do
        expect(subject).to eq({
          :repo_token     => repo_token,
          :service_name   => "surf",
          :service_branch => "surf-branch",
          :commit_sha     => "surf-commit",
        })
      end
    end

    context "for Wercker" do
      before_each do
        ENV["WERCKER"] = "1"
        ENV["WERCKER_BUILD_ID"] = "w-job-id"
        ENV["WERCKER_GIT_BRANCH"] = "w-branch"
        ENV["WERCKER_GIT_COMMIT"] = "w-commit"
      end

      it "provides custom options" do
        expect(subject).to eq({
          :repo_token     => repo_token,
          :service_name   => "wercker",
          :service_job_id => "w-job-id",
          :service_branch => "w-branch",
          :commit_sha     => "w-commit",
        })
      end
    end
  end
end
