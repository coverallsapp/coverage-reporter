require "option_parser"
require "./coverage_reporter"
require "colorize"

filename = ""
repo_token = ENV.fetch("COVERALLS_REPO_TOKEN", "")
config_path = CoverageReporter::Config::DEFAULT_LOCATION
job_flag = ""

parser = OptionParser.parse do |parser|
  parser.banner = "Usage coveralls [arguments]"
  parser.on(
    "-rTOKEN",
    "--repo-token=TOKEN",
    "Sets coveralls repo token, overrides settings in yaml or environment variable"
    ) do |token|
      repo_token = token
    end

  parser.on(
    "-cPATH",
    "--config-path=PATH",
    "Set the coveralls yaml config file location, will default to check '.coveralls.yml'"
    ) do |path|
      config_path = path
    end

  parser.on("-fFILENAME", "--file=FILENAME ", "Coverage artifact file to be reported, e.g. coverage/lcov.info") do |name|
    filename = name
  end

  parser.on("-jFLAG", "--job-flag=FLAG", "Coverage job flag name, e.g. Unit Tests") do |flag|
    job_flag = flag
  end

  parser.on("-h", "--help", "Show this help") do
    # TODO: add environment variable notes
    puts parser
    puts "Coveralls Coverage Reporter v#{CoverageReporter::VERSION}"
  end
end

begin
  puts "                                       #{"j".colorize(Colorize::Color256.new(88))}#{"i".colorize(Colorize::Color256.new(196))}#{"y".colorize(Colorize::Color256.new(88))}"
  puts "                                      #{"f".colorize(Colorize::Color256.new(88))}#{"lfl".colorize(Colorize::Color256.new(196))}#{"v".colorize(Colorize::Color256.new(88))}"
  puts "                                     #{"p".colorize(Colorize::Color256.new(88))}#{"wwwww".colorize(Colorize::Color256.new(196))}#{"q".colorize(Colorize::Color256.new(88))}"
  puts "                               #{"l".colorize(Colorize::Color256.new(88))}#{"jtttttwwwwwtttttj".colorize(Colorize::Color256.new(196))}#{"l".colorize(Colorize::Color256.new(88))}"
  puts "                                  #{"p".colorize(Colorize::Color256.new(88))}#{"jwwwwwwwwwj".colorize(Colorize::Color256.new(196))}#{"q".colorize(Colorize::Color256.new(88))}"
  puts "                                    #{"m".colorize(Colorize::Color256.new(88))}#{"wwwewww".colorize(Colorize::Color256.new(196))}#{"k".colorize(Colorize::Color256.new(88))}"
  puts "                                  #{"n".colorize(Colorize::Color256.new(88))}#{"jwwj".colorize(Colorize::Color256.new(196))}#{"v".colorize(Colorize::Color256.new(88))} #{"v".colorize(Colorize::Color256.new(88))}#{"jwwy".colorize(Colorize::Color256.new(196))}#{"n".colorize(Colorize::Color256.new(88))}"
  puts "                                 #{"m".colorize(Colorize::Color256.new(52))}#{"jy".colorize(Colorize::Color256.new(196))}#{"q".colorize(Colorize::Color256.new(88))}       #{"p".colorize(Colorize::Color256.new(88))}#{"gj".colorize(Colorize::Color256.new(196))}#{"m".colorize(Colorize::Color256.new(52))}"
  puts " "
  puts "        #{"g".colorize(Colorize::Color256.new(240))}vwww#{"y".colorize(Colorize::Color256.new(240))}  #{"v".colorize(Colorize::Color256.new(240))}www#{"g".colorize(Colorize::Color256.new(240))}  #{";".colorize(Colorize::Color256.new(240))}ww  www :wwww  vwnwng     nwv    ywp   ywp    ywww"
  puts "      #{"f".colorize(Colorize::Color256.new(240))}nwn#{"*".colorize(Colorize::Color256.new(240))}''  ww#{"n".colorize(Colorize::Color256.new(240))} ww: #{".".colorize(Colorize::Color256.new(240))}ww  ww  wwr   #{":".colorize(Colorize::Color256.new(240))}fw vww#{"v".colorize(Colorize::Color256.new(240))}  #{"f".colorize(Colorize::Color256.new(240))}wnmw#{"n".colorize(Colorize::Color256.new(240))}   ww#{";".colorize(Colorize::Color256.new(240))}   ww#{";".colorize(Colorize::Color256.new(240))}   ww#{"*".colorize(Colorize::Color256.new(240))}''"
  puts "     #{"v".colorize(Colorize::Color256.new(240))}fww     ww#{"j".colorize(Colorize::Color256.new(240))}  ww#{"g".colorize(Colorize::Color256.new(240))} #{".".colorize(Colorize::Color256.new(240))}ww ww  :wwww  fwm#{"e".colorize(Colorize::Color256.new(240))}ny   #{"f".colorize(Colorize::Color256.new(240))}ww #{";".colorize(Colorize::Color256.new(240))}ww  #{"f".colorize(Colorize::Color256.new(240))}ww   #{"f".colorize(Colorize::Color256.new(240))}ww    www:"
  puts "     #{"n".colorize(Colorize::Color256.new(240))}www#{"v".colorize(Colorize::Color256.new(240))}    ww  #{"v".colorize(Colorize::Color256.new(240))}ww#{"y".colorize(Colorize::Color256.new(240))}  ww#{":".colorize(Colorize::Color256.new(240))}wf  www    www'ww   wwwoowwi fww   fww     :ww;"
  puts "      #{"m".colorize(Colorize::Color256.new(240))}wwww#{"l".colorize(Colorize::Color256.new(240))}  #{"v".colorize(Colorize::Color256.new(240))}wwwon#{"n".colorize(Colorize::Color256.new(240))}   wwwf  :wwwww #{"v".colorize(Colorize::Color256.new(240))}ww  wwi lwwi  wwl lwwww lwwww iswj#{"v".colorize(Colorize::Color256.new(240))}"
  puts " "
  puts "  v#{CoverageReporter::VERSION}\n\n"

  CoverageReporter.run(filename, repo_token, config_path, job_flag)
rescue ex : ArgumentError
  STDERR.puts <<-ERROR
  Oops! #{ex.message}
  #{parser}
  Coveralls Coverage Reporter v#{CoverageReporter::VERSION}
  ERROR
rescue ex : Crest::UnprocessableEntity
  STDERR.puts <<-ERROR
  ---
  Error: #{ex.message}
  ---
  🚨 Oops! It looks like your request was not processible by Coveralls.
  This is often the is the result of an incorrectly set repo token.
  More info/troubleshooting here: https://docs.coveralls.io
  - 💛, Coveralls
  ERROR
end
