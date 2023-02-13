require "io"
require "process"

module CoverageReporter
  # General Git information required for Coveralls API.
  module Git
    extend self

    def info(config)
      head = Head.new

      {
        :branch => config[:service_branch]? || branch,
        :head   => {
          :id              => config[:commit_sha]? || head.commit,
          :committer_email => head.committer_email,
          :committer_name  => head.committer_email,
          :author_email    => head.author_email,
          :author_name     => head.author_name,
          :message         => head.message,
        }.compact,
      }.compact
    end

    private class Head
      @info : Array(String)?

      def commit
        ENV["GIT_ID"]? || info[0].presence
      end

      def author_name
        ENV["GIT_AUTHOR_NAME"]? || info[1]?.presence
      end

      def author_email
        ENV["GIT_AUTHOR_EMAIL"]? || info[2]?.presence
      end

      def committer_name
        ENV["GIT_COMMITTER_NAME"]? || info[3]?.presence
      end

      def committer_email
        ENV["GIT_COMMITTER_EMAIL"]? || info[4]?.presence
      end

      def message
        ENV["GIT_MESSAGE"]? || info[5]?.presence
      end

      # Returns git-related info about the HEAD.
      #
      # Git format explanation:
      #   %H  - commit hash
      #   %n  - newline
      #   %aN - author, respecting mailmap (see: https://www.git-scm.com/docs/gitmailmap)
      #   %aE - author email, respecting mailmap
      #   %cN - committer name, respecting mailmap
      #   %cE - committer email, respecting mailmap
      #   %s  - commit subject
      private def info
        @info ||= Git.command_line(
          "git log -1 --pretty=format:'%H%n%aN%n%aE%n%cN%n%cE%n%s'"
        ).split("\n")
      end
    end

    protected def command_line(command) : String
      io = IO::Memory.new
      Process.run(command, shell: true, output: io)
      io.to_s
    end

    private def branch : String
      ENV["GIT_BRANCH"]?.presence ||
        command_line("git rev-parse --abbrev-ref HEAD").rchop
    end
  end
end
