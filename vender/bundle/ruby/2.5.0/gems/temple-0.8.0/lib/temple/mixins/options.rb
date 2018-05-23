module Temple
  module Mixins
    # @api public
    module ClassOptions
      def set_default_options(opts)
        warn 'set_default_options has been deprecated, use set_options'
        set_options(opts)
      end

      def default_options
        warn 'default_options has been deprecated, use options'
        options
      end

      def set_options(opts)
        options.update(opts)
      end

      def options
        @options ||= OptionMap.new(superclass.respond_to?(:options) ?
                                   superclass.options : nil) do |hash, key, what|
          warn "#{self}: Option #{key.inspect} is #{what}" unless @option_validator_disabled
        end
      end

      def define_options(*opts)
        if opts.last.respond_to?(:to_hash)
          hash = opts.pop.to_hash
          options.add_valid_keys(hash.keys)
          options.update(hash)
        end
        options.add_valid_keys(opts)
      end

      def define_deprecated_options(*opts)
        if opts.last.respond_to?(:to_hash)
          hash = opts.pop.to_hash
          options.add_deprecated_keys(hash.keys)
          options.update(hash)
        end
        options.add_deprecated_keys(opts)
      end

      def disable_option_validator!
        @option_validator_disabled = true
      end
    end

    module ThreadOptions
      def with_options(options)
        old_options = thread_options
        Thread.current[thread_options_key] = ImmutableMap.new(options, thread_options)
        yield
      ensure
        Thread.current[thread_options_key] = old_options
      end

      def thread_options
        Thread.current[thread_options_key]
      end

      protected

      def thread_options_key
        @thread_options_key ||= "#{self.name}-thread-options".to_sym
      end
    end

    # @api public
    module Options
      def self.included(base)
        base.class_eval do
          extend ClassOptions
          extend ThreadOptions
        end
      end

      attr_reader :options

      def initialize(opts = {})
        self.class.options.validate_map!(opts)
        self.class.options.validate_map!(self.class.thread_options) if self.class.thread_options
        @options = ImmutableMap.new({}.update(self.class.options).update(self.class.thread_options || {}).update(opts))
      end
    end
  end
end
