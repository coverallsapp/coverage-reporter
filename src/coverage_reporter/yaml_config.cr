require "yaml"

module CoverageReporter
  class YamlConfig
    def initialize(yaml_filepath)
      @config = File.exists?(yaml_filepath) ? YAML.parse(File.read(yaml_filepath)) : {} of String => String
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
