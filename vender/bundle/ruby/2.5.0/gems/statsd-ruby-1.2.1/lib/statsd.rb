require 'socket'
require 'forwardable'

# = Statsd: A Statsd client (https://github.com/etsy/statsd)
#
# @example Set up a global Statsd client for a server on localhost:9125
#   $statsd = Statsd.new 'localhost', 8125
# @example Send some stats
#   $statsd.increment 'garets'
#   $statsd.timing 'glork', 320
#   $statsd.gauge 'bork', 100
# @example Use {#time} to time the execution of a block
#   $statsd.time('account.activate') { @account.activate! }
# @example Create a namespaced statsd client and increment 'account.activate'
#   statsd = Statsd.new('localhost').tap{|sd| sd.namespace = 'account'}
#   statsd.increment 'activate'
#
# Statsd instances are thread safe for general usage, by using a thread local
# UDPSocket and carrying no state. The attributes are stateful, and are not
# mutexed, it is expected that users will not change these at runtime in
# threaded environments. If users require such use cases, it is recommend that
# users either mutex around their Statsd object, or create separate objects for
# each namespace / host+port combination.
class Statsd

  # = Batch: A batching statsd proxy
  #
  # @example Batch a set of instruments using Batch and manual flush:
  #   $statsd = Statsd.new 'localhost', 8125
  #   batch = Statsd::Batch.new($statsd)
  #   batch.increment 'garets'
  #   batch.timing 'glork', 320
  #   batch.gauge 'bork', 100
  #   batch.flush
  #
  # Batch is a subclass of Statsd, but with a constructor that proxies to a
  # normal Statsd instance. It has it's own batch_size and namespace parameters
  # (that inherit defaults from the supplied Statsd instance). It is recommended
  # that some care is taken if setting very large batch sizes. If the batch size
  # exceeds the allowed packet size for UDP on your network, communication
  # troubles may occur and data will be lost.
  class Batch < Statsd

    extend Forwardable
    def_delegators :@statsd,
      :namespace, :namespace=,
      :host, :host=,
      :port, :port=,
      :prefix,
      :postfix

    attr_accessor :batch_size

    # @param [Statsd] requires a configured Statsd instance
    def initialize(statsd)
      @statsd = statsd
      @batch_size = statsd.batch_size
      @backlog = []
    end

    # @yields [Batch] yields itself
    #
    # A convenience method to ensure that data is not lost in the event of an
    # exception being thrown. Batches will be transmitted on the parent socket
    # as soon as the batch is full, and when the block finishes.
    def easy
      yield self
    ensure
      flush
    end

    def flush
      unless @backlog.empty?
        @statsd.send_to_socket @backlog.join("\n")
        @backlog.clear
      end
    end

    protected

    def send_to_socket(message)
      @backlog << message
      if @backlog.size >= @batch_size
        flush
      end
    end

  end


  # A namespace to prepend to all statsd calls.
  attr_reader :namespace

  # StatsD host. Defaults to 127.0.0.1.
  attr_reader :host

  # StatsD port. Defaults to 8125.
  attr_reader :port

  # StatsD namespace prefix, generated from #namespace
  attr_reader :prefix

  # The default batch size for new batches (default: 10)
  attr_accessor :batch_size

  # a postfix to append to all metrics
  attr_reader :postfix

  class << self
    # Set to a standard logger instance to enable debug logging.
    attr_accessor :logger
  end

  # @param [String] host your statsd host
  # @param [Integer] port your statsd port
  def initialize(host = '127.0.0.1', port = 8125)
    self.host, self.port = host, port
    @prefix = nil
    @batch_size = 10
    @postfix = nil
  end

  # @attribute [w] namespace
  #   Writes are not thread safe.
  def namespace=(namespace)
    @namespace = namespace
    @prefix = "#{namespace}."
  end

  # @attribute [w] postfix
  #   A value to be appended to the stat name after a '.'. If the value is
  #   blank then the postfix will be reset to nil (rather than to '.').
  def postfix=(pf)
    case pf
    when nil, false, '' then @postfix = nil
    else @postfix = ".#{pf}"
    end
  end

  # @attribute [w] host
  #   Writes are not thread safe.
  def host=(host)
    @host = host || '127.0.0.1'
  end

  # @attribute [w] port
  #   Writes are not thread safe.
  def port=(port)
    @port = port || 8125
  end

  # Sends an increment (count = 1) for the given stat to the statsd server.
  #
  # @param [String] stat stat name
  # @param [Numeric] sample_rate sample rate, 1 for always
  # @see #count
  def increment(stat, sample_rate=1)
    count stat, 1, sample_rate
  end

  # Sends a decrement (count = -1) for the given stat to the statsd server.
  #
  # @param [String] stat stat name
  # @param [Numeric] sample_rate sample rate, 1 for always
  # @see #count
  def decrement(stat, sample_rate=1)
    count stat, -1, sample_rate
  end

  # Sends an arbitrary count for the given stat to the statsd server.
  #
  # @param [String] stat stat name
  # @param [Integer] count count
  # @param [Numeric] sample_rate sample rate, 1 for always
  def count(stat, count, sample_rate=1)
    send_stats stat, count, :c, sample_rate
  end

  # Sends an arbitary gauge value for the given stat to the statsd server.
  #
  # This is useful for recording things like available disk space,
  # memory usage, and the like, which have different semantics than
  # counters.
  #
  # @param [String] stat stat name.
  # @param [Numeric] value gauge value.
  # @param [Numeric] sample_rate sample rate, 1 for always
  # @example Report the current user count:
  #   $statsd.gauge('user.count', User.count)
  def gauge(stat, value, sample_rate=1)
    send_stats stat, value, :g, sample_rate
  end

  # Sends an arbitary set value for the given stat to the statsd server.
  #
  # This is for recording counts of unique events, which are useful to
  # see on graphs to correlate to other values.  For example, a deployment
  # might get recorded as a set, and be drawn as annotations on a CPU history
  # graph.
  #
  # @param [String] stat stat name.
  # @param [Numeric] value event value.
  # @param [Numeric] sample_rate sample rate, 1 for always
  # @example Report a deployment happening:
  #   $statsd.set('deployment', DEPLOYMENT_EVENT_CODE)
  def set(stat, value, sample_rate=1)
    send_stats stat, value, :s, sample_rate
  end

  # Sends a timing (in ms) for the given stat to the statsd server. The
  # sample_rate determines what percentage of the time this report is sent. The
  # statsd server then uses the sample_rate to correctly track the average
  # timing for the stat.
  #
  # @param [String] stat stat name
  # @param [Integer] ms timing in milliseconds
  # @param [Numeric] sample_rate sample rate, 1 for always
  def timing(stat, ms, sample_rate=1)
    send_stats stat, ms, :ms, sample_rate
  end

  # Reports execution time of the provided block using {#timing}.
  #
  # @param [String] stat stat name
  # @param [Numeric] sample_rate sample rate, 1 for always
  # @yield The operation to be timed
  # @see #timing
  # @example Report the time (in ms) taken to activate an account
  #   $statsd.time('account.activate') { @account.activate! }
  def time(stat, sample_rate=1)
    start = Time.now
    result = yield
    timing(stat, ((Time.now - start) * 1000).round, sample_rate)
    result
  end

  # Creates and yields a Batch that can be used to batch instrument reports into
  # larger packets. Batches are sent either when the packet is "full" (defined
  # by batch_size), or when the block completes, whichever is the sooner.
  #
  # @yield [Batch] a statsd subclass that collects and batches instruments
  # @example Batch two instument operations:
  #   $statsd.batch do |batch|
  #     batch.increment 'sys.requests'
  #     batch.gauge('user.count', User.count)
  #   end
  def batch(&block)
    Batch.new(self).easy &block
  end

  protected

  def send_to_socket(message)
    self.class.logger.debug { "Statsd: #{message}" } if self.class.logger
    socket.send(message, 0, @host, @port)
  rescue => boom
    self.class.logger.error { "Statsd: #{boom.class} #{boom}" } if self.class.logger
    nil
  end

  private

  def send_stats(stat, delta, type, sample_rate=1)
    if sample_rate == 1 or rand < sample_rate
      # Replace Ruby module scoping with '.' and reserved chars (: | @) with underscores.
      stat = stat.to_s.gsub('::', '.').tr(':|@', '_')
      rate = "|@#{sample_rate}" unless sample_rate == 1
      send_to_socket "#{prefix}#{stat}#{postfix}:#{delta}|#{type}#{rate}"
    end
  end

  def socket
    Thread.current[:statsd_socket] ||= UDPSocket.new
  end
end
