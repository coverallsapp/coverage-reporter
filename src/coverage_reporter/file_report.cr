class FileReport
  getter name, coverage, branches

  def initialize(
    @name : String,
    @coverage : Array(Int32?),
    @branches : Array(Int32?) | Nil = nil
  )
  end

  def to_h : Hash(Symbol, String | Array(Int32?))
    {
      :name     => @name,
      :coverage => @coverage,
      :branches => @branches,
    }.compact
  end
end
