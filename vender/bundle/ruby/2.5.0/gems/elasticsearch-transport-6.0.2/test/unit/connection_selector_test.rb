require 'test_helper'

class Elasticsearch::Transport::Transport::Connections::SelectorTest < Test::Unit::TestCase
  include Elasticsearch::Transport::Transport::Connections::Selector

  class DummyStrategySelector
    include Elasticsearch::Transport::Transport::Connections::Selector::Base
  end

  class BackupStrategySelector
    include Elasticsearch::Transport::Transport::Connections::Selector::Base

    def select(options={})
      connections.reject do |c|
        c.host[:attributes] && c.host[:attributes][:backup]
      end.send( defined?(RUBY_VERSION) && RUBY_VERSION > '1.9' ? :sample : :choice)
    end
  end

  context "Connection selector" do

    should "be initialized with connections" do
      assert_equal [1, 2], Random.new(:connections => [1, 2]).connections
    end

    should "have the abstract select method" do
      assert_raise(NoMethodError) { DummyStrategySelector.new.select }
    end

    context "in random strategy" do
      setup do
        @selector = Random.new :connections => ['A', 'B', 'C']
      end

      should "pick a connection" do
        assert_not_nil @selector.select
      end
    end

    context "in round-robin strategy" do
      setup do
        @selector = RoundRobin.new :connections => ['A', 'B', 'C']
      end

      should "rotate over connections" do
        assert_equal 'A', @selector.select
        assert_equal 'B', @selector.select
        assert_equal 'C', @selector.select
        assert_equal 'A', @selector.select
      end
    end

    context "with a custom strategy" do

      should "return proper connection" do
        selector = BackupStrategySelector.new :connections => [ stub(:host => { :hostname => 'host1' }),
                                                                stub(:host => { :hostname => 'host2', :attributes => { :backup => true }}) ]
        10.times { assert_equal 'host1', selector.select.host[:hostname] }
      end

    end

  end
end
