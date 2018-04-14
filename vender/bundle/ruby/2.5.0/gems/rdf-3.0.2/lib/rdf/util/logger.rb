# coding: utf-8
require 'logger'

module RDF; module Util
  ##
  # Helpers for logging errors, warnings and debug information.
  #
  # Modules must provide `@logger`, which returns an instance of `Logger`, or something responding to `#<<`. Logger may also be specified using an `@options` hash containing a `:logger` entry.
  # @since 2.0.0
  module Logger
    ##
    # Logger instance, found using `options[:logger]`, `@logger`, or `@options[:logger]`
    # @param [Hash{Symbol => Object}] options
    # @option options [Logger, #<<] :logger
    # @return [Logger, #write, #<<]
    def logger(**options)
      logger = options.fetch(:logger, @logger)
      logger = @options[:logger] if logger.nil? && @options
      if logger.nil?
        # Unless otherwise specified, use $stderr
        logger = (@options || options)[:logger] = $stderr

        # Reset log_statistics so that it's not inherited across different instances
        logger.log_statistics.clear if logger.respond_to?(:log_statistics)
      end
      logger = (@options || options)[:logger] = ::Logger.new(::File.open(::File::NULL, "w"))  unless logger # Incase false was used, which is frozen
      logger.extend(LoggerBehavior) unless logger.is_a?(LoggerBehavior)
      logger
    end

    ##
    # Number of times logger has been called at each level
    # @param [Hash{Symbol => Object}] options
    # @option options [Logger, #<<] :logger
    # @return [Hash{Symbol => Integer}]
    def log_statistics(**options)
      logger(options).log_statistics
    end

    ##
    # Used for fatal errors where processing cannot continue. If `logger` is not configured, it logs to `$stderr`.
    #
    # @overload log_fatal(*args, **options, &block)
    #   @param [Array<String>] args
    #   @param [Array<String>] args Messages
    #   @param [:fatal, :error, :warn, :info, :debug] level (:fatal)
    #   @param [Hash{Symbol => Object}] options
    #   @option options [Integer] :depth
    #     Recursion depth for indenting output
    #   @option options [Integer] :lineno associated with message
    #   @option options [Logger, #<<] :logger
    #   @option options [Class] :exception, (StandardError)
    #     Exception class used for raising error
    #   @yieldreturn [String] added to message
    #   @return [void]
    #   @raise Raises the provided exception class using the first element from args as the message component.
    def log_fatal(*args, level: :fatal, **options, &block)
      logger_common(*args, "Called from #{Gem.location_of_caller.join(':')}", level: level, **options, &block)
      raise options.fetch(:exception, StandardError), args.first
    end

    ##
    # Used for non-fatal errors where processing can continue. If `logger` is not configured, it logs to `$stderr`.
    #
    # As a side-effect of setting `@logger_in_error`, which will suppress further error messages until cleared using {#log_recover}.
    #
    # @overload log_error(*args, **options, &block)
    #   @param [Array<String>] args
    #   @param [Array<String>] args Messages
    #   @param [:fatal, :error, :warn, :info, :debug] level (:error)
    #   @param [Hash{Symbol => Object}] options
    #   @option options [Integer] :depth
    #     Recursion depth for indenting output
    #   @option options [:fatal, :error, :warn, :info, :debug] level (:<<)
    #   @option options [Integer] :lineno associated with message
    #   @option options [Logger, #<<] :logger
    #   @option options [Class] :exception, (StandardError)
    #     Exception class used for raising error
    #   @yieldreturn [String] added to message
    #   @return [void]
    #   @raise Raises the provided exception class using the first element from args as the message component, if `:exception` option is provided.
    def log_error(*args, level: :error, **options, &block)
      logger = self.logger(options)
      return if logger.recovering
      logger.recovering = true
      logger_common(*args, level: level, **options, &block)
      raise options[:exception], args.first if options[:exception]
    end

    # In recovery mode? When `log_error` is called, we enter recovery mode. This is cleared when `log_recover` is called.
    # @param [Hash{Symbol => Object}] options
    # @option options [Logger, #<<] :logger
    # @return [Boolean]
    def log_recovering?(**options)
      self.logger(options).recovering
    end

    ##
    # Warning message.
    #
    # @overload log_warn(*args, **options, &block)
    #   @param [Array<String>] args
    #   @param [Array<String>] args Messages
    #   @param [:fatal, :error, :warn, :info, :debug] level (:warn)
    #   @param [Hash{Symbol => Object}] options
    #   @option options [Integer] :depth
    #     Recursion depth for indenting output
    #   @option options [:fatal, :error, :warn, :info, :debug] level (:<<)
    #   @option options [Integer] :lineno associated with message
    #   @option options [Logger, #<<] :logger
    #   @yieldreturn [String] added to message
    #   @return [void]
    def log_warn(*args, level: :warn, **options, &block)
      logger_common(*args, level: level, **options, &block)
    end

    ##
    # Recovers from an error condition. If `args` are passed, sent as an informational message
    #
    # As a side-effect of clearing `@logger_in_error`.
    #
    # @overload log_recover(*args, **options, &block)
    #   @param [Array<String>] args
    #   @param [Array<String>] args Messages
    #   @param [:fatal, :error, :warn, :info, :debug] level (:info)
    #   @param [Hash{Symbol => Object}] options
    #   @option options [Integer] :depth
    #     Recursion depth for indenting output
    #   @option options [Integer] :lineno associated with message
    #   @option options [Logger, #<<] :logger
    #   @yieldreturn [String] added to message
    #   @return [void]
    def log_recover(*args, level: :info, **options, &block)
      logger = self.logger(options)
      logger.recovering = false
      return if args.empty? && !block_given?
      logger_common(*args, level: level, **options, &block)
    end

    ##
    # Informational message.
    #
    # @overload log_info(*args, **options, &block)
    #   @param [Array<String>] args
    #   @param [Array<String>] args Messages
    #   @param [:fatal, :error, :warn, :info, :debug] level (:info)
    #   @param [Hash{Symbol => Object}] options
    #   @option options [Integer] :depth
    #     Recursion depth for indenting output
    #   @option options [Integer] :lineno associated with message
    #   @option options [Logger, #<<] :logger
    #   @yieldreturn [String] added to message
    #   @return [void]
    def log_info(*args, level: :info, **options, &block)
      logger_common(*args, level: level, **options, &block)
    end

    ##
    # Debug message.
    #
    # @overload log_debug(*args, **options, &block)
    #   @param [Array<String>] args
    #   @param [Array<String>] args Messages
    #   @param [:fatal, :error, :warn, :info, :debug] level (:debug)
    #   @param [Hash{Symbol => Object}] options
    #   @option options [Integer] :depth
    #     Recursion depth for indenting output
    #   @option options [Integer] :lineno associated with message
    #   @option options [Logger, #<<] :logger
    #   @yieldreturn [String] added to message
    #   @return [void]
    def log_debug(*args, level: :debug, **options, &block)
      logger_common(*args, level: level, **options, &block)
    end

    ##
    # @overload log_depth(options, &block)
    #   Increase depth around a method invocation
    #   @param [Hash{Symbol}] options (@options || {})
    #   @option options [Integer] :depth Additional recursion depth
    #   @option options [Logger, #<<] :logger
    #   @yield
    #     Yields with no arguments
    #   @yieldreturn [Object] returns the result of yielding
    #   @return [Object]
    #
    # @overload log_depth
    #   # Return the current log depth
    #   @return [Integer]
    def log_depth(**options, &block)
      self.logger(options).log_depth(&block)
    end

  private
    LOGGER_COMMON_LEVELS = {
      fatal: 4, error: 3, warn: 2, info: 1, debug: 0
    }.freeze
    LOGGER_COMMON_LEVELS_REVERSE = LOGGER_COMMON_LEVELS.invert.freeze

    ##
    # Common method for logging messages
    #
    # The call is ignored, unless `@logger` or `@options[:logger]` is set, in which case it records tracing information as indicated.
    #
    # @overload logger_common(args, options)
    #   @param [Array<String>] args Messages
    #   @param [:fatal, :error, :warn, :info, :debug] level
    #   @param [Hash{Symbol => Object}] options
    #   @option options [Integer] :depth
    #     Recursion depth for indenting output
    #   @option options [:fatal, :error, :warn, :info, :debug] level (:<<)
    #   @option options [Integer] :lineno associated with message
    #   @option options [Logger, #<<] :logger
    #   @yieldreturn [String] added to message
    #   @return [void]
    def logger_common(*args, level:, **options)
      logger = self.logger(options)
      logger.log_statistics[level] = logger.log_statistics[level].to_i + 1
      # Some older code uses integer level numbers
      level = LOGGER_COMMON_LEVELS_REVERSE.fetch(level) if level.is_a?(Integer)
      return if logger.level > LOGGER_COMMON_LEVELS.fetch(level)

      depth = options.fetch(:depth, logger.log_depth)
      args << yield if block_given?
      str = (depth > 100 ? ' ' * 100 + '+' : ' ' * depth) + args.join(": ")
      str = "[line #{options[:lineno]}] #{str}" if options[:lineno]
      logger.send(level, str)
    end

    ##
    # Module which is mixed-in to found logger to provide statistics and depth behavior
    module LoggerBehavior
      attr_accessor :recovering

      def log_statistics
        @logger_statistics ||= {}
      end

      ##
      # @overload log_depth(options, &block)
      #   Increase depth around a method invocation
      #   @param [Integer] depth (1) recursion depth
      #   @param [Hash{Symbol}] options (@options || {})
      #   @option options [Logger, #<<] :logger
      #   @yield
      #     Yields with no arguments
      #   @yieldreturn [Object] returns the result of yielding
      #   @return [Object]
      #
      # @overload log_depth
      #   # Return the current log depth
      #   @return [Integer]
      def log_depth(depth: 1, **options)
        @log_depth ||= 0
        if block_given?
          @log_depth += depth
          yield
        else
          @log_depth
        end
      ensure
        @log_depth -= depth if block_given?
      end

      # Give Logger like behavior to non-logger objects
      def method_missing(method, *args)
        case method.to_sym
        when :fatal, :error, :warn, :info, :debug
          if self.respond_to?(:write)
            self.write "#{method.to_s.upcase} #{(args.join(": "))}\n"
          elsif self.respond_to?(:<<)
            self << "#{method.to_s.upcase} #{args.join(": ")}"
          else
            # Silently eat the message
          end
        when :level, :sev_threshold then 2
        else
          super
        end
      end
      
      def respond_to_missing?(name, include_private = false)
        return true if 
          [:fatal, :error, :warn, :info, :debug, :level, :sev_threshold]
          .include?(name.to_sym)
        super
      end
    end
  end # Logger
end; end # RDF::Util
