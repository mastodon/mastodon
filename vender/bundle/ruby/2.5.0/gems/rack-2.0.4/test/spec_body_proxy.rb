require 'minitest/autorun'
require 'rack/body_proxy'
require 'stringio'

describe Rack::BodyProxy do
  it 'call each on the wrapped body' do
    called = false
    proxy  = Rack::BodyProxy.new(['foo']) { }
    proxy.each do |str|
      called = true
      str.must_equal 'foo'
    end
    called.must_equal true
  end

  it 'call close on the wrapped body' do
    body  = StringIO.new
    proxy = Rack::BodyProxy.new(body) { }
    proxy.close
    body.must_be :closed?
  end

  it 'only call close on the wrapped body if it responds to close' do
    body  = []
    proxy = Rack::BodyProxy.new(body) { }
    proxy.close.must_be_nil
  end

  it 'call the passed block on close' do
    called = false
    proxy  = Rack::BodyProxy.new([]) { called = true }
    called.must_equal false
    proxy.close
    called.must_equal true
  end

  it 'call the passed block on close even if there is an exception' do
    object = Object.new
    def object.close() raise "No!" end
    called = false

    begin
      proxy  = Rack::BodyProxy.new(object) { called = true }
      called.must_equal false
      proxy.close
    rescue RuntimeError => e
    end

    raise "Expected exception to have been raised" unless e
    called.must_equal true
  end

  it 'allow multiple arguments in respond_to?' do
    body  = []
    proxy = Rack::BodyProxy.new(body) { }
    proxy.respond_to?(:foo, false).must_equal false
  end

  it 'not respond to :to_ary' do
    body = Object.new.tap { |o| def o.to_ary() end }
    body.respond_to?(:to_ary).must_equal true

    proxy = Rack::BodyProxy.new(body) { }
    proxy.respond_to?(:to_ary).must_equal false
    proxy.respond_to?("to_ary").must_equal false
  end

  it 'not close more than one time' do
    count = 0
    proxy = Rack::BodyProxy.new([]) { count += 1; raise "Block invoked more than 1 time!" if count > 1 }
    2.times { proxy.close }
    count.must_equal 1
  end

  it 'be closed when the callback is triggered' do
    closed = false
    proxy = Rack::BodyProxy.new([]) { closed = proxy.closed? }
    proxy.close
    closed.must_equal true
  end

  it 'provide an #each method' do
    Rack::BodyProxy.method_defined?(:each).must_equal true
  end
end
