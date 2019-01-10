require "yaml"

module CoverageReporter
  class YamlConfig
    def initialize(yaml_filepath)
      @config = YAML.parse(File.read(yaml_filepath))
    end

    def repo_token
      return unless @config

      @config["repo_token"]
    end

    def config
      @config
    end
  end
end
