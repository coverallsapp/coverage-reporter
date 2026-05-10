require "./base_parser"
require "digest"

module CoverageReporter
  class LuaCovParser < BaseParser
    def globs : Array(String)
      [
        "luacov.report.out",
        "**/*/luacov.report.out",
      ]
    end

    def matches?(filename : String) : Bool
      return false unless File.exists?(filename)

      # below, we are going to check for one header in the
      # beginning of the file formatted as follows:
      #
      # ============
      # filename
      # ============

      # parser states
      parser_state_none : Int32 = 0                # initial state
      parser_state_header_top_line : Int32 = 1     # the top line of a header    (========)
      parser_state_header_content_line : Int32 = 2 # the content of the header   (filename)

      state = parser_state_none
      header_line : String? = nil

      File.each_line(filename, chomp: true) do |line|
        # top line of a header
        if state == parser_state_none && /^=+$/.matches?(line)
          state = parser_state_header_top_line
          header_line = line

          # filename
        elsif state == parser_state_header_top_line && /^.+$/.matches?(line)
          state = parser_state_header_content_line

          # bottom line of a header
        elsif state == parser_state_header_content_line && header_line == line
          return true
        else
          return false
        end
      end

      false
    end

    def parse(filename : String) : Array(FileReport)
      # below, we are going to parse a list of headers and line info,
      # while the filename in the header is not "Summary".
      #
      # Basic structure:
      #
      # =============
      # filename-1
      # =============
      # line info 1
      # line info 2
      # .
      # .
      # .
      #
      # =============
      # filename-2
      # =============
      # line info 1
      # line info 2
      # .
      # .
      # .
      #
      # =============
      # Summary
      # =============

      # parser states
      parser_state_invalid : Int32 = -2            # an error/invalid rule was found
      parser_state_ok : Int32 = -1                 # file was parsed successfully
      parser_state_none : Int32 = 0                # initial state
      parser_state_header_top_line : Int32 = 1     # the top line of a header    (========)
      parser_state_header_content_line : Int32 = 2 # the content of the header   (filename)
      parser_state_header_bottom_line : Int32 = 3  # the bottom line of a header (========)
      parser_state_line_info : Int32 = 4           # the line info containing hits / misses

      state = parser_state_none
      header_line : String? = nil
      name : String? = nil
      coverage = Array(Hits?).new
      reports = Array(FileReport).new

      File.each_line(filename, chomp: true) do |line|
        # top line of a header
        if (state == parser_state_none || state == parser_state_line_info) && /^=+$/.matches?(line)
          if state == parser_state_line_info
            if name
              reports << file_report(name, coverage.dup)
              coverage.clear
            else
              state = parser_state_invalid
              break
            end
          end
          state = parser_state_header_top_line
          header_line = line

          # the content of a header (not empty)
        elsif state == parser_state_header_top_line && /^.+$/.matches?(line)
          state = parser_state_header_content_line
          name = line

          # bottom line of a header matching the header top line
        elsif state == parser_state_header_content_line && header_line == line
          # if the header content is "Summary", finish the parser
          if name == "Summary"
            state = parser_state_ok
            break
            # otherwise, it is the end of a usual file header
          else
            state = parser_state_header_bottom_line
          end

          # handle line info to extract hits
        elsif state == parser_state_header_bottom_line || state == parser_state_line_info
          # check for miss
          if /^\*+0 /.matches?(line)
            state = parser_state_line_info
            coverage << 0_u64

            # check for a line with hits
          elsif match = line.match(/^\s+([0-9]+) /)
            state = parser_state_line_info
            number_of_hits = match[1].to_u64?
            # is it a valid UInt64?
            if number_of_hits && number_of_hits > 0_u64
              coverage << number_of_hits
              # otherwise, it is a number too large to fit into a UInt64
            else
              state = parser_state_invalid
              break
            end

            # the line is not relevant
          else
            state = parser_state_line_info
            coverage << nil
          end
          # unknown combination of state and line matching
        else
          state = parser_state_invalid
          break
        end
      end

      # if the parser finished
      # on any state other than ok,
      # clear the reports
      if state != parser_state_ok
        reports.clear
      end

      reports
    end
  end
end
