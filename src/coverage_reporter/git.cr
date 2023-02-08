require "io"
require "process"

module CoverageReporter
  module Git
    extend self

    def info
      {
        :head => {
          :id             => ENV.fetch("GIT_ID", command_line("git log -1 --pretty=format:'%H'")),
          :commiter_email => ENV.fetch("GIT_AUTHOR_NAME", command_line("git log -1 --pretty=format:'%aN'")),
          :committer_name => ENV.fetch("GIT_AUTHOR_EMAIL", command_line("git log -1 --pretty=format:'%ae'")),
          :author_email   => ENV.fetch("GIT_COMMITTER_NAME", command_line("git log -1 --pretty=format:'%cN'")),
          :author_name    => ENV.fetch("GIT_COMMITTER_EMAIL", command_line("git log -1 --pretty=format:'%ce'")),
          :message        => ENV.fetch("GIT_MESSAGE", command_line("git log -1 --pretty=format:'%s'")),
        },
        :branch => ENV.fetch("GIT_BRANCH", command_line("git rev-parse --abbrev-ref HEAD").rchop),
      }
    end

    private def command_line(command)
      io = IO::Memory.new
      Process.run(command, shell: true, output: io)
      io.to_s
    end
  end
end
