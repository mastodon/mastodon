require 'test_helper'

class Elasticsearch::Transport::Transport::Connections::CollectionTest < Test::Unit::TestCase
  include Elasticsearch::Transport::Transport::Connections

  context "Connection collection" do

    should "have empty array as default connections array" do
      assert_equal [], Collection.new.connections
    end

    should "have default selector class" do
      assert_not_nil Collection.new.selector
    end

    should "initialize a custom selector class" do
      c = Collection.new :selector_class => Selector::Random
      assert_instance_of Selector::Random, c.selector
    end

    should "take a custom selector instance" do
      c = Collection.new :selector => Selector::Random.new
      assert_instance_of Selector::Random, c.selector
    end

    should "get connection from selector" do
      c = Collection.new
      c.selector.expects(:select).returns('OK')
      assert_equal 'OK', c.get_connection
    end

    should "return an array of hosts" do
      c = Collection.new :connections => [ Connection.new(:host => 'foo'), Connection.new(:host => 'bar') ]
      assert_equal ['foo', 'bar'], c.hosts
    end

    should "be enumerable" do
      c = Collection.new :connections => [ Connection.new(:host => 'foo'), Connection.new(:host => 'bar') ]

      assert_equal ['FOO', 'BAR'], c.map { |i| i.host.upcase }
      assert_equal 'foo',          c[0].host
      assert_equal 'bar',          c[1].host
      assert_equal  2,             c.size
    end

    should "add connections" do
      c = Collection.new :connections => [ Connection.new(:host => { :protocol => 'http', :host => 'foo', :port => 1}) ]
      assert_equal 1, c.size

      c.add([ Connection.new(:host => { :protocol => 'http', :host => 'bar', :port => 1 }),
              Connection.new(:host => { :protocol => 'http', :host => 'bam', :port => 1 }) ])
      assert_equal 3, c.size
    end

    should "add connection" do
      c = Collection.new :connections => [ Connection.new(:host => { :protocol => 'http', :host => 'foo', :port => 1}) ]
      assert_equal 1, c.size

      c.add(Connection.new(:host => { :protocol => 'http', :host => 'bar', :port => 1 }))
      assert_equal 2, c.size
    end

    should "remove connections" do
      c = Collection.new :connections => [
        Connection.new(:host => { :protocol => 'http', :host => 'foo', :port => 1 }),
        Connection.new(:host => { :protocol => 'http', :host => 'bar', :port => 1 })
      ]
      assert_equal 2, c.size

      c.remove([c.first])
      assert_equal 1, c.size

      c.remove(c)
      assert_equal 0, c.size
    end

    should "remove connection" do
      c = Collection.new :connections => [
        Connection.new(:host => { :protocol => 'http', :host => 'foo', :port => 1 }),
        Connection.new(:host => { :protocol => 'http', :host => 'bar', :port => 1 })
      ]
      assert_equal 2, c.size

      c.remove(c.first)
      assert_equal 1, c.size
    end

    context "with the dead pool" do
      setup do
        @collection = Collection.new :connections => [ Connection.new(:host => 'foo'), Connection.new(:host => 'bar') ]
        @collection[1].dead!
      end

      should "not iterate over dead connections" do
        assert_equal 1, @collection.size
        assert_equal ['FOO'], @collection.map { |c| c.host.upcase }
        assert_equal @collection.connections, @collection.alive
      end

      should "have dead connections collection" do
        assert_equal 1, @collection.dead.size
        assert_equal ['BAR'], @collection.dead.map { |c| c.host.upcase }
      end

      should "not return dead connections, when alive connections exist" do
        assert_equal 1, @collection.size
        @collection.all.size.times { refute @collection.get_connection.dead? }
      end

      should "resurrect dead connection with least failures when no alive is available" do
        c1 = Connection.new(:host => { :protocol => 'http', :host => 'foo', :port => 123 }).dead!.dead!
        c2 = Connection.new(:host => { :protocol => 'http', :host => 'bar', :port => 123 }).dead!

        @collection = Collection.new :connections => [ c1, c2 ]

        assert_equal 0, @collection.size
        assert_not_nil @collection.get_connection
        assert_equal 1, @collection.size
        assert_equal c2, @collection.first
      end

      should "return all connections" do
        assert_equal 2, @collection.all.size
      end

    end

  end

end
