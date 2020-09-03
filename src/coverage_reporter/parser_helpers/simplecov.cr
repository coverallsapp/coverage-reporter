module CoverageReporter
  module ParserHelpers
    class SimpleCov
      alias SourceFilesType = Hash(Symbol, Array(Int32 | Nil) | String)

      def initialize(@tracefile : String)
      end

      def parse : Array(SourceFilesType)
        source_files = [] of SourceFilesType

        results = Hash(String, Hash(String, Hash(String, Array(Int32 | Nil)) | Int32)).from_json File.read @tracefile

        results.each do |test_runner, output|
          # Need to cast again to prevent the "timestamp": Int32 field from erroring:
          output["coverage"].as(Hash(String, Array(Int32 | Nil))).each do |filename, coverage|
            source_files.push({
              :name => filename.sub(Dir.current,""), 
              :coverage => coverage
            })
          end
        end

        source_files
      end

    end
  end
end
