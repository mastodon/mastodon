require 'minitest/autorun'
require 'rack/lint'
require 'rack/lock'
require 'rack/mock'

class Lock
  attr_reader :synchronized

  def initialize
    @synchronized = false
  end

  def lock
    @synchronized = true
  end

  def unlock
    @synchronized = false
  end
end

module LockHelpers
  def lock_app(app, lock = Lock.new)
    app = if lock
      Rack::Lock.new app, lock
    else
      Rack::Lock.new app
    end
    Rack::Lint.new app
  end
end

describe Rack::Lock do
  include LockHelpers

  describe 'Proxy' do
    include LockHelpers

    it 'delegate each' do
      env      = Rack::MockRequest.env_for("/")
      response = Class.new {
        attr_accessor :close_called
        def initialize; @close_called = false; end
        def each; %w{ hi mom }.each { |x| yield x }; end
      }.new

      app = lock_app(lambda { |inner_env| [200, {"Content-Type" => "text/plain"}, response] })
      response = app.call(env)[2]
      list = []
      response.each { |x| list << x }
      list.must_equal %w{ hi mom }
    end

    it 'delegate to_path' do
      lock = Lock.new
      env  = Rack::MockRequest.env_for("/")

      res = ['Hello World']
      def res.to_path ; "/tmp/hello.txt" ; end

      app = Rack::Lock.new(lambda { |inner_env| [200, {"Content-Type" => "text/plain"}, res] }, lock)
      body = app.call(env)[2]

      body.must_respond_to :to_path
      body.to_path.must_equal "/tmp/hello.txt"
    end

    it 'not delegate to_path if body does not implement it' do
      env  = Rack::MockRequest.env_for("/")

      res = ['Hello World']

      app = lock_app(lambda { |inner_env| [200, {"Content-Type" => "text/plain"}, res] })
      body = app.call(env)[2]

      body.wont_respond_to :to_path
    end
  end

  it 'call super on close' do
    env      = Rack::MockRequest.env_for("/")
    response = Class.new {
      attr_accessor :close_called
      def initialize; @close_called = false; end
      def close; @close_called = true; end
    }.new

    app = lock_app(lambda { |inner_env| [200, {"Content-Type" => "text/plain"}, response] })
    app.call(env)
    response.close_called.must_equal false
    response.close
    response.close_called.must_equal true
  end

  it "not unlock until body is closed" do
    lock     = Lock.new
    env      = Rack::MockRequest.env_for("/")
    response = Object.new
    app      = lock_app(lambda { |inner_env| [200, {"Content-Type" => "text/plain"}, response] }, lock)
    lock.synchronized.must_equal false
    response = app.call(env)[2]
    lock.synchronized.must_equal true
    response.close
    lock.synchronized.must_equal false
  end

  it "return value from app" do
    env  = Rack::MockRequest.env_for("/")
    body = [200, {"Content-Type" => "text/plain"}, %w{ hi mom }]
    app  = lock_app(lambda { |inner_env| body })

    res = app.call(env)
    res[0].must_equal body[0]
    res[1].must_equal body[1]
    res[2].to_enum.to_a.must_equal ["hi", "mom"]
  end

  it "call synchronize on lock" do
    lock = Lock.new
    env = Rack::MockRequest.env_for("/")
    app = lock_app(lambda { |inner_env| [200, {"Content-Type" => "text/plain"}, %w{ a b c }] }, lock)
    lock.synchronized.must_equal false
    app.call(env)
    lock.synchronized.must_equal true
  end

  it "unlock if the app raises" do
    lock = Lock.new
    env = Rack::MockRequest.env_for("/")
    app = lock_app(lambda { raise Exception }, lock)
    lambda { app.call(env) }.must_raise Exception
    lock.synchronized.must_equal false
  end

  it "unlock if the app throws" do
    lock = Lock.new
    env = Rack::MockRequest.env_for("/")
    app = lock_app(lambda {|_| throw :bacon }, lock)
    lambda { app.call(env) }.must_throw :bacon
    lock.synchronized.must_equal false
  end

  it "set multithread flag to false" do
    app = lock_app(lambda { |env|
      env['rack.multithread'].must_equal false
      [200, {"Content-Type" => "text/plain"}, %w{ a b c }]
    }, false)
    env = Rack::MockRequest.env_for("/")
    env['rack.multithread'].must_equal true
    _, _, body = app.call(env)
    body.close
    env['rack.multithread'].must_equal true
  end

  it "reset original multithread flag when exiting lock" do
    app = Class.new(Rack::Lock) {
      def call(env)
        env['rack.multithread'].must_equal true
        super
      end
    }.new(lambda { |env| [200, {"Content-Type" => "text/plain"}, %w{ a b c }] })
    Rack::Lint.new(app).call(Rack::MockRequest.env_for("/"))
  end

  it 'not unlock if an error is raised before the mutex is locked' do
    lock = Class.new do
      def initialize() @unlocked = false end
      def unlocked?() @unlocked end
      def lock() raise Exception end
      def unlock() @unlocked = true end
    end.new
    env = Rack::MockRequest.env_for("/")
    app = lock_app(proc { [200, {"Content-Type" => "text/plain"}, []] }, lock)
    lambda { app.call(env) }.must_raise Exception
    lock.unlocked?.must_equal false
  end

  it "not reset the environment while the body is proxied" do
    proxy = Class.new do
      attr_reader :env
      def initialize(env) @env = env end
    end
    app = Rack::Lock.new lambda { |env| [200, {"Content-Type" => "text/plain"}, proxy.new(env)] }
    response = app.call(Rack::MockRequest.env_for("/"))[2]
    response.env['rack.multithread'].must_equal false
  end

  it "unlock if an exception occurs before returning" do
    lock = Lock.new
    env  = Rack::MockRequest.env_for("/")
    app  = lock_app(proc { [].freeze }, lock)
    lambda { app.call(env) }.must_raise Exception
    lock.synchronized.must_equal false
  end

  it "not replace the environment" do
    env  = Rack::MockRequest.env_for("/")
    app  = lock_app(lambda { |inner_env| [200, {"Content-Type" => "text/plain"}, [inner_env.object_id.to_s]] })

    _, _, body = app.call(env)

    body.to_enum.to_a.must_equal [env.object_id.to_s]
  end
end
