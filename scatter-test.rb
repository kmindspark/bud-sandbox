require_relative 'scatter'

module ScatterTest
  import Scatter => :s

  state do
    table :tmp
  end

  bootstrap do
    tmp <= [[0, [2, 3, 4, 6, 7, 8, 4, 234, 65, 2, -3, 4]]]
  end

  bloom do
    s.data_scatter <= tmp
    stdio <~ s.received_scatter.inspected
  end
end