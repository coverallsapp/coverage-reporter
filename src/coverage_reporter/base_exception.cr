module CoverageReporter
  # Exception used in utility logic just to be catched and printed.
  class BaseException < Exception
    property? fail : Bool

    def initialize(@fail : Bool = true)
      super()
    end
  end
end
