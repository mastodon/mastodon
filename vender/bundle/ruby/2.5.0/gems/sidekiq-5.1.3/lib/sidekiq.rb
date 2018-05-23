# frozen_string_literal: true
require 'sidekiq/version'
fail "Sidekiq #{Sidekiq::VERSION} does not support Ruby versions below 2.2.2." if RUBY_PLATFORM != 'java' && Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.2.2')

require 'sidekiq/logging'
require 'sidekiq/client'
require 'sidekiq/worker'
require 'sidekiq/redis_connection'
require 'sidekiq/delay'

require 'json'

module Sidekiq
  NAME = 'Sidekiq'
  LICENSE = 'See LICENSE and the LGPL-3.0 for licensing details.'

  DEFAULTS = {
    queues: [],
    labels: [],
    concurrency: 25,
    require: '.',
    environment: nil,
    timeout: 8,
    poll_interval_average: nil,
    average_scheduled_poll_interval: 5,
    error_handlers: [],
    death_handlers: [],
    lifecycle_events: {
      startup: [],
      quiet: [],
      shutdown: [],
      heartbeat: [],
    },
    dead_max_jobs: 10_000,
    dead_timeout_in_seconds: 180 * 24 * 60 * 60, # 6 months
    reloader: proc { |&block| block.call },
  }

  DEFAULT_WORKER_OPTIONS = {
    'retry' => true,
    'queue' => 'default'
  }

  FAKE_INFO = {
    "redis_version" => "9.9.9",
    "uptime_in_days" => "9999",
    "connected_clients" => "9999",
    "used_memory_human" => "9P",
    "used_memory_peak_human" => "9P"
  }

  def self.❨╯°□°❩╯︵┻━┻
    puts "Calm down, yo."
  end

  def self.options
    @options ||= DEFAULTS.dup
  end
  def self.options=(opts)
    @options = opts
  end

  ##
  # Configuration for Sidekiq server, use like:
  #
  #   Sidekiq.configure_server do |config|
  #     config.redis = { :namespace => 'myapp', :size => 25, :url => 'redis://myhost:8877/0' }
  #     config.server_middleware do |chain|
  #       chain.add MyServerHook
  #     end
  #   end
  def self.configure_server
    yield self if server?
  end

  ##
  # Configuration for Sidekiq client, use like:
  #
  #   Sidekiq.configure_client do |config|
  #     config.redis = { :namespace => 'myapp', :size => 1, :url => 'redis://myhost:8877/0' }
  #   end
  def self.configure_client
    yield self unless server?
  end

  def self.server?
    defined?(Sidekiq::CLI)
  end

  def self.redis
    raise ArgumentError, "requires a block" unless block_given?
    redis_pool.with do |conn|
      retryable = true
      begin
        yield conn
      rescue Redis::CommandError => ex
        #2550 Failover can cause the server to become a slave, need
        # to disconnect and reopen the socket to get back to the master.
        (conn.disconnect!; retryable = false; retry) if retryable && ex.message =~ /READONLY/
        raise
      end
    end
  end

  def self.redis_info
    redis do |conn|
      begin
        # admin commands can't go through redis-namespace starting
        # in redis-namespace 2.0
        if conn.respond_to?(:namespace)
          conn.redis.info
        else
          conn.info
        end
      rescue Redis::CommandError => ex
        #2850 return fake version when INFO command has (probably) been renamed
        raise unless ex.message =~ /unknown command/
        FAKE_INFO
      end
    end
  end

  def self.redis_pool
    @redis ||= Sidekiq::RedisConnection.create
  end

  def self.redis=(hash)
    @redis = if hash.is_a?(ConnectionPool)
      hash
    else
      Sidekiq::RedisConnection.create(hash)
    end
  end

  def self.client_middleware
    @client_chain ||= Middleware::Chain.new
    yield @client_chain if block_given?
    @client_chain
  end

  def self.server_middleware
    @server_chain ||= default_server_middleware
    yield @server_chain if block_given?
    @server_chain
  end

  def self.default_server_middleware
    Middleware::Chain.new
  end

  def self.default_worker_options=(hash)
    # stringify
    @default_worker_options = default_worker_options.merge(Hash[hash.map{|k, v| [k.to_s, v]}])
  end
  def self.default_worker_options
    defined?(@default_worker_options) ? @default_worker_options : DEFAULT_WORKER_OPTIONS
  end

  def self.default_retries_exhausted=(prok)
    logger.info { "default_retries_exhausted is deprecated, please use `config.death_handlers << -> {|job, ex| }`" }
    return nil unless prok
    death_handlers << prok
  end

  ##
  # Death handlers are called when all retries for a job have been exhausted and
  # the job dies.  It's the notification to your application
  # that this job will not succeed without manual intervention.
  #
  # Sidekiq.configure_server do |config|
  #   config.death_handlers << ->(job, ex) do
  #   end
  # end
  def self.death_handlers
    options[:death_handlers]
  end

  def self.load_json(string)
    JSON.parse(string)
  end
  def self.dump_json(object)
    JSON.generate(object)
  end

  def self.logger
    Sidekiq::Logging.logger
  end
  def self.logger=(log)
    Sidekiq::Logging.logger = log
  end

  # How frequently Redis should be checked by a random Sidekiq process for
  # scheduled and retriable jobs. Each individual process will take turns by
  # waiting some multiple of this value.
  #
  # See sidekiq/scheduled.rb for an in-depth explanation of this value
  def self.average_scheduled_poll_interval=(interval)
    self.options[:average_scheduled_poll_interval] = interval
  end

  # Register a proc to handle any error which occurs within the Sidekiq process.
  #
  #   Sidekiq.configure_server do |config|
  #     config.error_handlers << proc {|ex,ctx_hash| MyErrorService.notify(ex, ctx_hash) }
  #   end
  #
  # The default error handler logs errors to Sidekiq.logger.
  def self.error_handlers
    self.options[:error_handlers]
  end

  # Register a block to run at a point in the Sidekiq lifecycle.
  # :startup, :quiet or :shutdown are valid events.
  #
  #   Sidekiq.configure_server do |config|
  #     config.on(:shutdown) do
  #       puts "Goodbye cruel world!"
  #     end
  #   end
  def self.on(event, &block)
    raise ArgumentError, "Symbols only please: #{event}" unless event.is_a?(Symbol)
    raise ArgumentError, "Invalid event name: #{event}" unless options[:lifecycle_events].key?(event)
    options[:lifecycle_events][event] << block
  end

  # We are shutting down Sidekiq but what about workers that
  # are working on some long job?  This error is
  # raised in workers that have not finished within the hard
  # timeout limit.  This is needed to rollback db transactions,
  # otherwise Ruby's Thread#kill will commit.  See #377.
  # DO NOT RESCUE THIS ERROR IN YOUR WORKERS
  class Shutdown < Interrupt; end
end

require 'sidekiq/rails' if defined?(::Rails::Engine)
