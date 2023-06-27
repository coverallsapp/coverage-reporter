class ReporterMock
  alias Settings = String | Bool | Nil | Array(String) | CoverageReporter::CI::Options
  getter settings : Hash(Symbol, Settings)

  def initialize(*args, **kwargs)
    @settings = {} of Symbol => Settings
  end

  def configure(*args, **kwargs)
    @settings = kwargs.to_h
  end

  def report
  end

  def parallel_done
  end

  def overrides : CoverageReporter::CI::Options
    settings[:overrides].as(CoverageReporter::CI::Options)
  end

  macro method_missing(key)
    def {{ key.id }}
      settings[{{ key.symbolize }}]
    end
  end
end
