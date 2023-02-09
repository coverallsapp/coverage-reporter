require "yaml"

module CoverageReporter
  class YamlConfig
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
