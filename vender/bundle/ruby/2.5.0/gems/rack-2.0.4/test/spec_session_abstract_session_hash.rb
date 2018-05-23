require 'minitest/autorun'
require 'rack/session/abstract/id'

describe Rack::Session::Abstract::SessionHash do
  attr_reader :hash

  def setup
    super
    store = Class.new do
      def load_session(req)
        ["id", {foo: :bar, baz: :qux}]
      end
      def session_exists?(req)
        true
      end
    end
    @hash = Rack::Session::Abstract::SessionHash.new(store.new, nil)
  end

  it "returns keys" do
    assert_equal ["foo", "baz"], hash.keys
  end

  it "returns values" do
    assert_equal [:bar, :qux], hash.values
  end

  describe "#fetch" do
    it "returns value for a matching key" do
      assert_equal :bar, hash.fetch(:foo)
    end

    it "works with a default value" do
      assert_equal :default, hash.fetch(:unknown, :default)
    end

    it "works with a block" do
      assert_equal :default, hash.fetch(:unkown) { :default }
    end

    it "it raises when fetching unknown keys without defaults" do
      lambda { hash.fetch(:unknown) }.must_raise KeyError
    end
  end
end
