module CoverageReporter
  module ParserHelpers
    class SimpleCov
      alias SourceFilesType = Hash(Symbol, Array(Int32 | Nil) | String)

      alias CoverageOrHashType = Array(Int32 | Nil) | Hash(String, Array(Int32 | Nil));

      def initialize(@tracefile : String)
      end

      def parse : Array(SourceFilesType)
        source_files = [] of SourceFilesType

        # handle SimpleCov versions before 0.18 that don't include branch coverage
        results = Hash(String, Hash(String, Hash(String, CoverageOrHashType) | Int32)).from_json File.read @tracefile

        results.each do |test_runner, output|
          output["coverage"].as(Hash(String, CoverageOrHashType)).each do |filename, coverage_or_hash|

            coverage = [] of Int32 | Nil

            case coverage_or_hash
            when Array(Int32 | Nil)
              coverage = coverage_or_hash
            when Hash(String, Array(Int32 | Nil))
              coverage = coverage_or_hash["lines"]
              # TODO: handle coverage_or_hash["branches"]
            end

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
