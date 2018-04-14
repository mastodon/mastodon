require 'thread'
require 'concurrent/delay'
require 'concurrent/errors'
require 'concurrent/atomic/atomic_reference'
require 'concurrent/concern/logging'
require 'concurrent/executor/immediate_executor'
require 'concurrent/utility/at_exit'
require 'concurrent/utility/processor_counter'

module Concurrent
  extend Concern::Logging

  autoload :Options, 'concurrent/options'
  autoload :TimerSet, 'concurrent/executor/timer_set'
  autoload :ThreadPoolExecutor, 'concurrent/executor/thread_pool_executor'

  # @return [Logger] Logger with provided level and output.
  def self.create_simple_logger(level = Logger::FATAL, output = $stderr)
    # TODO (pitr-ch 24-Dec-2016): figure out why it had to be replaced, stdlogger was deadlocking
    lambda do |severity, progname, message = nil, &block|
      return false if severity < level

      message           = block ? block.call : message
      formatted_message = case message
                          when String
                            message
                          when Exception
                            format "%s (%s)\n%s",
                                   message.message, message.class, (message.backtrace || []).join("\n")
                          else
                            message.inspect
                          end

      output.print format "[%s] %5s -- %s: %s\n",
                          Time.now.strftime('%Y-%m-%d %H:%M:%S.%L'),
                          Logger::SEV_LABEL[severity],
                          progname,
                          formatted_message
      true
    end
  end

  # Use logger created by #create_simple_logger to log concurrent-ruby messages.
  def self.use_simple_logger(level = Logger::FATAL, output = $stderr)
    Concurrent.global_logger = create_simple_logger level, output
  end

  # @return [Logger] Logger with provided level and output.
  # @deprecated
  def self.create_stdlib_logger(level = Logger::FATAL, output = $stderr)
    logger           = Logger.new(output)
    logger.level     = level
    logger.formatter = lambda do |severity, datetime, progname, msg|
      formatted_message = case msg
                          when String
                            msg
                          when Exception
                            format "%s (%s)\n%s",
                                   msg.message, msg.class, (msg.backtrace || []).join("\n")
                          else
                            msg.inspect
                          end
      format "[%s] %5s -- %s: %s\n",
             datetime.strftime('%Y-%m-%d %H:%M:%S.%L'),
             severity,
             progname,
             formatted_message
    end

    lambda do |loglevel, progname, message = nil, &block|
      logger.add loglevel, message, progname, &block
    end
  end

  # Use logger created by #create_stdlib_logger to log concurrent-ruby messages.
  # @deprecated
  def self.use_stdlib_logger(level = Logger::FATAL, output = $stderr)
    Concurrent.global_logger = create_stdlib_logger level, output
  end

  # TODO (pitr-ch 27-Dec-2016): remove deadlocking stdlib_logger methods

  # Suppresses all output when used for logging.
  NULL_LOGGER   = lambda { |level, progname, message = nil, &block| }

  # @!visibility private
  GLOBAL_LOGGER = AtomicReference.new(create_simple_logger(Logger::WARN))
  private_constant :GLOBAL_LOGGER

  def self.global_logger
    GLOBAL_LOGGER.value
  end

  def self.global_logger=(value)
    GLOBAL_LOGGER.value = value
  end

  # @!visibility private
  GLOBAL_FAST_EXECUTOR = Delay.new { Concurrent.new_fast_executor(auto_terminate: true) }
  private_constant :GLOBAL_FAST_EXECUTOR

  # @!visibility private
  GLOBAL_IO_EXECUTOR = Delay.new { Concurrent.new_io_executor(auto_terminate: true) }
  private_constant :GLOBAL_IO_EXECUTOR

  # @!visibility private
  GLOBAL_TIMER_SET = Delay.new { TimerSet.new(auto_terminate: true) }
  private_constant :GLOBAL_TIMER_SET

  # @!visibility private
  GLOBAL_IMMEDIATE_EXECUTOR = ImmediateExecutor.new
  private_constant :GLOBAL_IMMEDIATE_EXECUTOR

  # Disables AtExit handlers including pool auto-termination handlers.
  # When disabled it will be the application programmer's responsibility
  # to ensure that the handlers are shutdown properly prior to application
  # exit by calling {AtExit.run} method.
  #
  # @note this option should be needed only because of `at_exit` ordering
  #   issues which may arise when running some of the testing frameworks.
  #   E.g. Minitest's test-suite runs itself in `at_exit` callback which
  #   executes after the pools are already terminated. Then auto termination
  #   needs to be disabled and called manually after test-suite ends.
  # @note This method should *never* be called
  #   from within a gem. It should *only* be used from within the main
  #   application and even then it should be used only when necessary.
  # @see AtExit
  def self.disable_at_exit_handlers!
    AtExit.enabled = false
  end

  # Global thread pool optimized for short, fast *operations*.
  #
  # @return [ThreadPoolExecutor] the thread pool
  def self.global_fast_executor
    GLOBAL_FAST_EXECUTOR.value
  end

  # Global thread pool optimized for long, blocking (IO) *tasks*.
  #
  # @return [ThreadPoolExecutor] the thread pool
  def self.global_io_executor
    GLOBAL_IO_EXECUTOR.value
  end

  def self.global_immediate_executor
    GLOBAL_IMMEDIATE_EXECUTOR
  end

  # Global thread pool user for global *timers*.
  #
  # @return [Concurrent::TimerSet] the thread pool
  def self.global_timer_set
    GLOBAL_TIMER_SET.value
  end

  # General access point to global executors.
  # @param [Symbol, Executor] executor_identifier symbols:
  #   - :fast - {Concurrent.global_fast_executor}
  #   - :io - {Concurrent.global_io_executor}
  #   - :immediate - {Concurrent.global_immediate_executor}
  # @return [Executor]
  def self.executor(executor_identifier)
    Options.executor(executor_identifier)
  end

  def self.new_fast_executor(opts = {})
    FixedThreadPool.new(
        [2, Concurrent.processor_count].max,
        auto_terminate:  opts.fetch(:auto_terminate, true),
        idletime:        60, # 1 minute
        max_queue:       0, # unlimited
        fallback_policy: :abort # shouldn't matter -- 0 max queue
    )
  end

  def self.new_io_executor(opts = {})
    ThreadPoolExecutor.new(
        min_threads:     [2, Concurrent.processor_count].max,
        max_threads:     ThreadPoolExecutor::DEFAULT_MAX_POOL_SIZE,
        # max_threads:     1000,
        auto_terminate:  opts.fetch(:auto_terminate, true),
        idletime:        60, # 1 minute
        max_queue:       0, # unlimited
        fallback_policy: :abort # shouldn't matter -- 0 max queue
    )
  end
end
