require 'rubygems'
require 'bud'
require 'test/unit'
require 'test/kvs_workloads'
require 'kvs/kvs'
require 'kvs/useful_combos'

class TestKVS < Test::Unit::TestCase
  include KVSWorkloads

  def initialize(args)
    @opts = {:dump => true, :visualize => 1, :scoping => false}
    super
  end

  def test_wl2
    # reliable delivery fails if the recipient is down
    v = SingleSiteKVS.new(:visualize => 1)
    assert_nothing_raised(RuntimeError) {v.run_bg}
    sleep 1
    #add_members(v, "localhost:12347", "localhost:12348")
    if v.is_a?  ReliableDelivery
      sleep 1
      workload1(v)
      assert_equal(0, v.kvstate.length)
    end
  end

  def ntest_wl5
    # the unmetered kvs fails on a disorderly workload
    v = SingleSiteKVS.new(@opts.merge(:port => 12352))
    assert_nothing_raised(RuntimeError) {v.run_bg}
    add_members(v, "localhost:12352")
    assert_raise(Bud::KeyConstraintError)  { workload2(v) }
  end

  def test_wl1
    # in a distributed, ordered workload, the right thing happens
    v = BestEffortReplicatedKVS.new(@opts.merge(:tag => 'dist_1', :port => 12345))
    v2 = BestEffortReplicatedKVS.new(@opts.merge(:tag => 'dist_2', :port => 12346))

    assert_nothing_raised(RuntimeError) {v.run_bg}
    assert_nothing_raised(RuntimeError) {v2.run_bg}

    puts "v2 port is #{v2.port}"
    add_members(v, "localhost:12345", "localhost:12346")
    add_members(v2, "localhost:12345", "localhost:12346")
    sleep 2
    workload1(v)
    sleep 2

    assert_equal(1, v.kvstate.length)
    assert_equal("bak", v.kvstate.first[1])
    assert_equal(1, v2.kvstate.length)
    assert_equal("bak", v2.kvstate.first[1])
  end

  def test_simple
    v = SingleSiteKVS.new(:port => 12360, :dump => true, :scoping => false, :visualize => 3, :tag => 'simple')
    assert_nothing_raised(RuntimeError) {v.run_bg}
    #add_members(v, "localhost:12360")
    sleep 1 
    workload1(v)
    assert_equal(1, v.kvstate.length)
    assert_equal("bak", v.kvstate.first[1])
  
    v.kvget <+ [[1234, 'foo']]
    sleep 3
  end
end

