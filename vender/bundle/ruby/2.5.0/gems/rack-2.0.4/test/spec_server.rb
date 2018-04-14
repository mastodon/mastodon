require 'minitest/autorun'
require 'rack'
require 'rack/server'
require 'tempfile'
require 'socket'
require 'open-uri'

module Minitest::Spec::DSL
  alias :should :it
end

describe Rack::Server do
  SPEC_ARGV = []

  before { SPEC_ARGV[0..-1] = [] }

  def app
    lambda { |env| [200, {'Content-Type' => 'text/plain'}, ['success']] }
  end

  def with_stderr
    old, $stderr = $stderr, StringIO.new
    yield $stderr
  ensure
    $stderr = old
  end

  it "overrides :config if :app is passed in" do
    server = Rack::Server.new(:app => "FOO")
    server.app.must_equal "FOO"
  end

  it "prefer to use :builder when it is passed in" do
    server = Rack::Server.new(:builder => "run lambda { |env| [200, {'Content-Type' => 'text/plain'}, ['success']] }")
    server.app.class.must_equal Proc
    Rack::MockRequest.new(server.app).get("/").body.to_s.must_equal 'success'
  end

  it "allow subclasses to override middleware" do
    server = Class.new(Rack::Server).class_eval { def middleware; Hash.new [] end; self }
    server.middleware['deployment'].wont_equal []
    server.new(:app => 'foo').middleware['deployment'].must_equal []
  end

  it "allow subclasses to override default middleware" do
    server = Class.new(Rack::Server).instance_eval { def default_middleware_by_environment; Hash.new [] end; self }
    server.middleware['deployment'].must_equal []
    server.new(:app => 'foo').middleware['deployment'].must_equal []
  end

  it "only provide default middleware for development and deployment environments" do
    Rack::Server.default_middleware_by_environment.keys.sort.must_equal %w(deployment development)
  end

  it "always return an empty array for unknown environments" do
    server = Rack::Server.new(:app => 'foo')
    server.middleware['production'].must_equal []
  end

  it "not include Rack::Lint in deployment environment" do
    server = Rack::Server.new(:app => 'foo')
    server.middleware['deployment'].flatten.wont_include Rack::Lint
  end

  it "not include Rack::ShowExceptions in deployment environment" do
    server = Rack::Server.new(:app => 'foo')
    server.middleware['deployment'].flatten.wont_include Rack::ShowExceptions
  end

  it "include Rack::TempfileReaper in deployment environment" do
    server = Rack::Server.new(:app => 'foo')
    server.middleware['deployment'].flatten.must_include Rack::TempfileReaper
  end

  it "support CGI" do
    begin
      o, ENV["REQUEST_METHOD"] = ENV["REQUEST_METHOD"], 'foo'
      server = Rack::Server.new(:app => 'foo')
      server.server.name =~ /CGI/
      Rack::Server.logging_middleware.call(server).must_be_nil
    ensure
      ENV['REQUEST_METHOD'] = o
    end
  end

  it "be quiet if said so" do
    server = Rack::Server.new(:app => "FOO", :quiet => true)
    Rack::Server.logging_middleware.call(server).must_be_nil
  end

  it "use a full path to the pidfile" do
    # avoids issues with daemonize chdir
    opts = Rack::Server.new.send(:parse_options, %w[--pid testing.pid])
    opts[:pid].must_equal ::File.expand_path('testing.pid')
  end

  it "get options from ARGV" do
    SPEC_ARGV[0..-1] = ['--debug', '-sthin', '--env', 'production']
    server = Rack::Server.new
    server.options[:debug].must_equal true
    server.options[:server].must_equal 'thin'
    server.options[:environment].must_equal 'production'
  end

  it "only override non-passed options from parsed .ru file" do
    builder_file = File.join(File.dirname(__FILE__), 'builder', 'options.ru')
    SPEC_ARGV[0..-1] = ['--debug', '-sthin', '--env', 'production', builder_file]
    server = Rack::Server.new
    server.app # force .ru file to be parsed

    server.options[:debug].must_equal true
    server.options[:server].must_equal 'thin'
    server.options[:environment].must_equal 'production'
    server.options[:Port].must_equal '2929'
  end

  it "run a server" do
    pidfile = Tempfile.open('pidfile') { |f| break f }
    FileUtils.rm pidfile.path
    server = Rack::Server.new(
      :app         => app,
      :environment => 'none',
      :pid         => pidfile.path,
      :Port        => TCPServer.open('127.0.0.1', 0){|s| s.addr[1] },
      :Host        => '127.0.0.1',
      :Logger      => WEBrick::Log.new(nil, WEBrick::BasicLog::WARN),
      :AccessLog   => [],
      :daemonize   => false,
      :server      => 'webrick'
    )
    t = Thread.new { server.start { |s| Thread.current[:server] = s } }
    t.join(0.01) until t[:server] && t[:server].status != :Stop
    body = open("http://127.0.0.1:#{server.options[:Port]}/") { |f| f.read }
    body.must_equal 'success'

    Process.kill(:INT, $$)
    t.join
    open(pidfile.path) { |f| f.read.must_equal $$.to_s }
  end

  it "check pid file presence and running process" do
    pidfile = Tempfile.open('pidfile') { |f| f.write($$); break f }.path
    server = Rack::Server.new(:pid => pidfile)
    server.send(:pidfile_process_status).must_equal :running
  end

  it "check pid file presence and dead process" do
    dead_pid = `echo $$`.to_i
    pidfile = Tempfile.open('pidfile') { |f| f.write(dead_pid); break f }.path
    server = Rack::Server.new(:pid => pidfile)
    server.send(:pidfile_process_status).must_equal :dead
  end

  it "check pid file presence and exited process" do
    pidfile = Tempfile.open('pidfile') { |f| break f }.path
    ::File.delete(pidfile)
    server = Rack::Server.new(:pid => pidfile)
    server.send(:pidfile_process_status).must_equal :exited
  end

  it "check pid file presence and not owned process" do
    pidfile = Tempfile.open('pidfile') { |f| f.write(1); break f }.path
    server = Rack::Server.new(:pid => pidfile)
    server.send(:pidfile_process_status).must_equal :not_owned
  end

  it "not write pid file when it is created after check" do
    pidfile = Tempfile.open('pidfile') { |f| break f }.path
    ::File.delete(pidfile)
    server = Rack::Server.new(:pid => pidfile)
    ::File.open(pidfile, 'w') { |f| f.write(1) }
    with_stderr do |err|
      lambda { server.send(:write_pid) }.must_raise SystemExit
      err.rewind
      output = err.read
      output.must_match(/already running/)
      output.must_include pidfile
    end
  end

  it "inform the user about existing pidfiles with running processes" do
    pidfile = Tempfile.open('pidfile') { |f| f.write(1); break f }.path
    server = Rack::Server.new(:pid => pidfile)
    with_stderr do |err|
      lambda { server.start }.must_raise SystemExit
      err.rewind
      output = err.read
      output.must_match(/already running/)
      output.must_include pidfile
    end
  end

end
