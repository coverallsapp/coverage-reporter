require "yaml"

module CoverageReporter
  # `.coveralls.yml` config representation.
  class YamlConfig
    include YAML::Serializable

    property service_name : String?
    property repo_token : String?
    property repo_secret_token : String?
    property repo_name : String?
    property endpoint : String?

    DEFAULT_LOCATION = ".coveralls.yml"

    def self.read(path)
      if File.exists?(path.to_s)
        self.from_yaml(File.read(path.to_s))
      else
        self.from_yaml("---\n")
      end
    end
  end
end
