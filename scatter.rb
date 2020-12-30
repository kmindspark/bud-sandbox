module Scatter
  state do
    #table :data_scatter
    #table :received_scatter
    table :ips_scatter
    table :ips_sender
    table :ips_len
    interface input, :data_scatter
    interface output, :received_scatter
    channel :message_func_scatter, [:@addr, :id] => [:val]
    periodic :timer, 1
  end

  bootstrap do
    ips_scatter <+ [[0, "127.0.0.1:12346"], [1, "127.0.0.1:12347"], [2, "127.0.0.1:12348"]]
    ips_sender <+ [[0, "127.0.0.1:12345"]]
  end

  bloom do
      ips_len <= ips_scatter.group([], count())
      message_func_scatter <~ (ips_scatter * ips_len * data_scatter * ips_sender * timer).combos {|i, l, d, is, t| [i.val, d.key, d.val[(d.val.length()/l.key)*i.key..(d.val.length()/l.key)*(i.key + 1)-1]] if $sender > 0}
      received_scatter <= message_func_scatter {|m| [m.id, m.val]}
  end
end