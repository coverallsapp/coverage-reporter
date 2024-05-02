require "./base_parser"

module CoverageReporter
  class CoverallsParser < BaseParser
    class SourceFiles
      include JSON::Serializable

      property name : String
      property coverage : Array(Hits?)
      property branches : Array(Hits) | Nil
      property source_digest : String?
    end

    class CoverallsFormat
      include JSON::Serializable

      property source_files : Array(SourceFiles)
    end

    def globs : Array(String)
      [
        "coveralls.json",
        "**/*/coveralls.json",
      ]
    end

    def matches?(filename : String) : Bool
      File.open(filename) do |f|
        parsed = JSON.parse(f)
        parsed["source_files"].as_a? != nil
      end
    rescue Exception
      false
    end

    def parse(filename : String) : Array(FileReport)
      data = CoverallsFormat.from_json(File.read(filename))
      data.source_files.map do |source_file|
        # name = File.join(@base_path.to_s, source_file.name)

        file_report(
          name: source_file.name,
          coverage: source_file.coverage,
          branches: source_file.branches,
          source_digest: source_file.source_digest,
        )
      end
    end
  end
end
