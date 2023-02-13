require "yaml"

module CoverageReporter
  # `.coveralls.yml` config representation.
  class YamlConfig
    DEFAULT_LOCATION = ".coveralls.yml"

    def initialize(path)
      @config =
        if File.exists?(path)
          YAML.parse(File.read(path))
        else
          {} of String => String
        end
    end

    delegate :[], to: @config
    delegate :[]?, to: @config
  end
end
