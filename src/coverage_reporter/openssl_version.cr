module CoverageReporter
  class OpenSSLVersion
    WORKS = SemanticVersion.new(1, 1, 0)

    def can_fail?
      return current.not_nil! < WORKS unless current.nil?

      false
    end

    private def current
      matches = /.*?(\d+)\.(\d+)\.(\d+).*/.match(current_string)
      return nil if matches.nil?

      major = matches[1].to_i
      minor = matches[2].to_i
      patch = matches[3].to_i
      SemanticVersion.new(major, minor, patch)
    end

    # TODO: rescue from unknown command
    # TODO: return nil for windows
    private def current_string
      # examples:
      #   OpenSSL 1.0.2k-fips  26 Jan 2017
      #   OpenSSL 3.0.8 7 Feb 2023 (Library: OpenSSL 3.0.8 7 Feb 2023)
      `openssl version -v`
    end
  end
end
