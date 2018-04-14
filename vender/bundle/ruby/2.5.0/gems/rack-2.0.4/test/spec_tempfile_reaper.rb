require 'minitest/autorun'
require 'rack/tempfile_reaper'
require 'rack/lint'
require 'rack/mock'

describe Rack::TempfileReaper do
  class MockTempfile
    attr_reader :closed

    def initialize
      @closed = false
    end

    def close!
      @closed = true
    end
  end

  before do
    @env = Rack::MockRequest.env_for
  end

  def call(app)
    Rack::Lint.new(Rack::TempfileReaper.new(app)).call(@env)
  end

  it 'do nothing (i.e. not bomb out) without env[rack.tempfiles]' do
    app = lambda { |_| [200, {}, ['Hello, World!']] }
    response = call(app)
    response[2].close
    response[0].must_equal 200
  end

  it 'close env[rack.tempfiles] when body is closed' do
    tempfile1, tempfile2 = MockTempfile.new, MockTempfile.new
    @env['rack.tempfiles'] = [ tempfile1, tempfile2 ]
    app = lambda { |_| [200, {}, ['Hello, World!']] }
    call(app)[2].close
    tempfile1.closed.must_equal true
    tempfile2.closed.must_equal true
  end

  it 'initialize env[rack.tempfiles] when not already present' do
    tempfile = MockTempfile.new
    app = lambda do |env|
      env['rack.tempfiles'] << tempfile
      [200, {}, ['Hello, World!']]
    end
    call(app)[2].close
    tempfile.closed.must_equal true
  end

  it 'append env[rack.tempfiles] when already present' do
    tempfile1, tempfile2 = MockTempfile.new, MockTempfile.new
    @env['rack.tempfiles'] = [ tempfile1 ]
    app = lambda do |env|
      env['rack.tempfiles'] << tempfile2
      [200, {}, ['Hello, World!']]
    end
    call(app)[2].close
    tempfile1.closed.must_equal true
    tempfile2.closed.must_equal true
  end
end
