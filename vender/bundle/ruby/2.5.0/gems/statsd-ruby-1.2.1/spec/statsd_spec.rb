require 'helper'

describe Statsd do
  class Statsd
    public :socket
  end

  before do
    @statsd = Statsd.new('localhost', 1234)
    @socket = Thread.current[:statsd_socket] = FakeUDPSocket.new
  end

  after { Thread.current[:statsd_socket] = nil }

  describe "#initialize" do
    it "should set the host and port" do
      @statsd.host.must_equal 'localhost'
      @statsd.port.must_equal 1234
    end

    it "should default the host to 127.0.0.1 and port to 8125" do
      statsd = Statsd.new
      statsd.host.must_equal '127.0.0.1'
      statsd.port.must_equal 8125
    end
  end

  describe "#host and #port" do
    it "should set host and port" do
      @statsd.host = '1.2.3.4'
      @statsd.port = 5678
      @statsd.host.must_equal '1.2.3.4'
      @statsd.port.must_equal 5678
    end

    it "should not resolve hostnames to IPs" do
      @statsd.host = 'localhost'
      @statsd.host.must_equal 'localhost'
    end

    it "should set nil host to default" do
      @statsd.host = nil
      @statsd.host.must_equal '127.0.0.1'
    end

    it "should set nil port to default" do
      @statsd.port = nil
      @statsd.port.must_equal 8125
    end
  end

  describe "#increment" do
    it "should format the message according to the statsd spec" do
      @statsd.increment('foobar')
      @socket.recv.must_equal ['foobar:1|c']
    end

    describe "with a sample rate" do
      before { class << @statsd; def rand; 0; end; end } # ensure delivery
      it "should format the message according to the statsd spec" do
        @statsd.increment('foobar', 0.5)
        @socket.recv.must_equal ['foobar:1|c|@0.5']
      end
    end
  end

  describe "#decrement" do
    it "should format the message according to the statsd spec" do
      @statsd.decrement('foobar')
      @socket.recv.must_equal ['foobar:-1|c']
    end

    describe "with a sample rate" do
      before { class << @statsd; def rand; 0; end; end } # ensure delivery
      it "should format the message according to the statsd spec" do
        @statsd.decrement('foobar', 0.5)
        @socket.recv.must_equal ['foobar:-1|c|@0.5']
      end
    end
  end

  describe "#gauge" do
    it "should send a message with a 'g' type, per the nearbuy fork" do
      @statsd.gauge('begrutten-suffusion', 536)
      @socket.recv.must_equal ['begrutten-suffusion:536|g']
      @statsd.gauge('begrutten-suffusion', -107.3)
      @socket.recv.must_equal ['begrutten-suffusion:-107.3|g']
    end

    describe "with a sample rate" do
      before { class << @statsd; def rand; 0; end; end } # ensure delivery
      it "should format the message according to the statsd spec" do
        @statsd.gauge('begrutten-suffusion', 536, 0.1)
        @socket.recv.must_equal ['begrutten-suffusion:536|g|@0.1']
      end
    end
  end

  describe "#timing" do
    it "should format the message according to the statsd spec" do
      @statsd.timing('foobar', 500)
      @socket.recv.must_equal ['foobar:500|ms']
    end

    describe "with a sample rate" do
      before { class << @statsd; def rand; 0; end; end } # ensure delivery
      it "should format the message according to the statsd spec" do
        @statsd.timing('foobar', 500, 0.5)
        @socket.recv.must_equal ['foobar:500|ms|@0.5']
      end
    end
  end

  describe "#set" do
    it "should format the message according to the statsd spec" do
      @statsd.set('foobar', 765)
      @socket.recv.must_equal ['foobar:765|s']
    end

    describe "with a sample rate" do
      before { class << @statsd; def rand; 0; end; end } # ensure delivery
      it "should format the message according to the statsd spec" do
        @statsd.set('foobar', 500, 0.5)
        @socket.recv.must_equal ['foobar:500|s|@0.5']
      end
    end
  end

  describe "#time" do
    it "should format the message according to the statsd spec" do
      @statsd.time('foobar') { 'test' }
      @socket.recv.must_equal ['foobar:0|ms']
    end

    it "should return the result of the block" do
      result = @statsd.time('foobar') { 'test' }
      result.must_equal 'test'
    end

    describe "with a sample rate" do
      before { class << @statsd; def rand; 0; end; end } # ensure delivery

      it "should format the message according to the statsd spec" do
        @statsd.time('foobar', 0.5) { 'test' }
        @socket.recv.must_equal ['foobar:0|ms|@0.5']
      end
    end
  end

  describe "#sampled" do
    describe "when the sample rate is 1" do
      before { class << @statsd; def rand; raise end; end }
      it "should send" do
        @statsd.timing('foobar', 500, 1)
        @socket.recv.must_equal ['foobar:500|ms']
      end
    end

    describe "when the sample rate is greater than a random value [0,1]" do
      before { class << @statsd; def rand; 0; end; end } # ensure delivery
      it "should send" do
        @statsd.timing('foobar', 500, 0.5)
        @socket.recv.must_equal ['foobar:500|ms|@0.5']
      end
    end

    describe "when the sample rate is less than a random value [0,1]" do
      before { class << @statsd; def rand; 1; end; end } # ensure no delivery
      it "should not send" do
        @statsd.timing('foobar', 500, 0.5).must_equal nil
      end
    end

    describe "when the sample rate is equal to a random value [0,1]" do
      before { class << @statsd; def rand; 0; end; end } # ensure delivery
      it "should send" do
        @statsd.timing('foobar', 500, 0.5)
        @socket.recv.must_equal ['foobar:500|ms|@0.5']
      end
    end
  end

  describe "with namespace" do
    before { @statsd.namespace = 'service' }

    it "should add namespace to increment" do
      @statsd.increment('foobar')
      @socket.recv.must_equal ['service.foobar:1|c']
    end

    it "should add namespace to decrement" do
      @statsd.decrement('foobar')
      @socket.recv.must_equal ['service.foobar:-1|c']
    end

    it "should add namespace to timing" do
      @statsd.timing('foobar', 500)
      @socket.recv.must_equal ['service.foobar:500|ms']
    end

    it "should add namespace to gauge" do
      @statsd.gauge('foobar', 500)
      @socket.recv.must_equal ['service.foobar:500|g']
    end
  end

  describe "with postfix" do
    before { @statsd.postfix = 'ip-23-45-56-78' }

    it "should add postfix to increment" do
      @statsd.increment('foobar')
      @socket.recv.must_equal ['foobar.ip-23-45-56-78:1|c']
    end

    it "should add postfix to decrement" do
      @statsd.decrement('foobar')
      @socket.recv.must_equal ['foobar.ip-23-45-56-78:-1|c']
    end

    it "should add namespace to timing" do
      @statsd.timing('foobar', 500)
      @socket.recv.must_equal ['foobar.ip-23-45-56-78:500|ms']
    end

    it "should add namespace to gauge" do
      @statsd.gauge('foobar', 500)
      @socket.recv.must_equal ['foobar.ip-23-45-56-78:500|g']
    end
  end

  describe '#postfix=' do
    describe "when nil, false, or empty" do
      it "should set postfix to nil" do
        [nil, false, ''].each do |value|
          @statsd.postfix = 'a postfix'
          @statsd.postfix = value
          @statsd.postfix.must_equal nil
        end
      end
    end
  end

  describe "with logging" do
    require 'stringio'
    before { Statsd.logger = Logger.new(@log = StringIO.new)}

    it "should write to the log in debug" do
      Statsd.logger.level = Logger::DEBUG

      @statsd.increment('foobar')

      @log.string.must_match "Statsd: foobar:1|c"
    end

    it "should not write to the log unless debug" do
      Statsd.logger.level = Logger::INFO

      @statsd.increment('foobar')

      @log.string.must_be_empty
    end
  end

  describe "stat names" do
    it "should accept anything as stat" do
      @statsd.increment(Object, 1)
    end

    it "should replace ruby constant delimeter with graphite package name" do
      class Statsd::SomeClass; end
      @statsd.increment(Statsd::SomeClass, 1)

      @socket.recv.must_equal ['Statsd.SomeClass:1|c']
    end

    it "should replace statsd reserved chars in the stat name" do
      @statsd.increment('ray@hostname.blah|blah.blah:blah', 1)
      @socket.recv.must_equal ['ray_hostname.blah_blah.blah_blah:1|c']
    end
  end

  describe "handling socket errors" do
    before do
      require 'stringio'
      Statsd.logger = Logger.new(@log = StringIO.new)
      @socket.instance_eval { def send(*) raise SocketError end }
    end

    it "should ignore socket errors" do
      @statsd.increment('foobar').must_equal nil
    end

    it "should log socket errors" do
      @statsd.increment('foobar')
      @log.string.must_match 'Statsd: SocketError'
    end
  end

  describe "batching" do
    it "should have a default batch size of 10" do
      @statsd.batch_size.must_equal 10
    end

    it "should have a modifiable batch size" do
      @statsd.batch_size = 7
      @statsd.batch_size.must_equal 7
      @statsd.batch do |b|
        b.batch_size.must_equal 7
      end
    end

    it "should flush the batch at the batch size or at the end of the block" do
      @statsd.batch do |b|
        b.batch_size = 3

        # The first three should flush, the next two will be flushed when the
        # block is done.
        5.times { b.increment('foobar') }

        @socket.recv.must_equal [(["foobar:1|c"] * 3).join("\n")]
      end

      @socket.recv.must_equal [(["foobar:1|c"] * 2).join("\n")]
    end

    it "should not flush to the socket if the backlog is empty" do
      batch = Statsd::Batch.new(@statsd)
      batch.flush
      @socket.recv.must_be :nil?

      batch.increment 'foobar'
      batch.flush
      @socket.recv.must_equal %w[foobar:1|c]
    end

    it "should support setting namespace for the underlying instance" do
      batch = Statsd::Batch.new(@statsd)
      batch.namespace = 'ns'
      @statsd.namespace.must_equal 'ns'
    end

    it "should support setting host for the underlying instance" do
      batch = Statsd::Batch.new(@statsd)
      batch.host = '1.2.3.4'
      @statsd.host.must_equal '1.2.3.4'
    end

    it "should support setting port for the underlying instance" do
      batch = Statsd::Batch.new(@statsd)
      batch.port = 42
      @statsd.port.must_equal 42
    end

  end

  describe "thread safety" do

    it "should use a thread local socket" do
      Thread.current[:statsd_socket].must_equal @socket
      @statsd.send(:socket).must_equal @socket
    end

    it "should create a new socket when used in a new thread" do
      sock = @statsd.send(:socket)
      Thread.new { Thread.current[:statsd_socket] }.value.wont_equal sock
    end

  end
end

describe Statsd do
  describe "with a real UDP socket" do
    it "should actually send stuff over the socket" do
      socket = UDPSocket.new
      host, port = 'localhost', 12345
      socket.bind(host, port)

      statsd = Statsd.new(host, port)
      statsd.increment('foobar')
      message = socket.recvfrom(16).first
      message.must_equal 'foobar:1|c'
    end
  end
end if ENV['LIVE']
