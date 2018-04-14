module Seahorse
  module Client
    class Plugin

      extend HandlerBuilder

      # @param [Configuration] config
      # @return [void]
      def add_options(config)
        self.class.options.each do |option|
          if option.default_block
            config.add_option(option.name, &option.default_block)
          else
            config.add_option(option.name, option.default)
          end
        end
      end

      # @param [HandlerList] handlers
      # @param [Configuration] config
      # @return [void]
      def add_handlers(handlers, config)
        handlers.copy_from(self.class.handlers)
      end

      # @param [Class<Client::Base>] client_class
      # @param [Hash] options
      # @return [void]
      def before_initialize(client_class, options)
        self.class.before_initialize_hooks.each do |block|
          block.call(client_class, options)
        end
      end

      # @param [Client::Base] client
      # @return [void]
      def after_initialize(client)
        self.class.after_initialize_hooks.each do |block|
          block.call(client)
        end
      end

      class << self

        # @overload option(name, options = {}, &block)
        # @option options [Object] :default Can also be set by passing a block.
        # @option options [String] :doc_default
        # @option options [Boolean] :required
        # @option options [String] :doc_type
        # @option options [String] :docs
        # @return [void]
        def option(name, default = nil, options = {}, &block)
          # For backwards-compat reasons, the default value can be passed as 2nd
          # positional argument (before the options hash) or as the `:default` option
          # in the options hash.
          if Hash === default
            options = default
          else
            options[:default] = default
          end
          options[:default_block] = Proc.new if block_given?
          self.options << PluginOption.new(name, options)
        end

        def before_initialize(&block)
          before_initialize_hooks << block
        end

        def after_initialize(&block)
          after_initialize_hooks << block
        end

        # @api private
        def options
          @options ||= []
        end

        # @api private
        def handlers
          @handlers ||= HandlerList.new
        end

        # @api private
        def before_initialize_hooks
          @before_initialize_hooks ||= []
        end

        # @api private
        def after_initialize_hooks
          @after_initialize_hooks ||= []
        end

        # @api private
        def literal(string)
          CodeLiteral.new(string)
        end

        # @api private
        class CodeLiteral < String
          def inspect
            to_s
          end
        end

      end

      # @api private
      class PluginOption

        def initialize(name, options = {})
          @name = name
          options.each_pair do |opt_name, opt_value|
            self.send("#{opt_name}=", opt_value)
          end
        end

        attr_reader :name
        attr_accessor :default
        attr_accessor :default_block
        attr_accessor :required
        attr_accessor :doc_type
        attr_accessor :doc_default
        attr_accessor :docstring

        def doc_default
          if @doc_default.nil?
            Proc === default ? nil : default
          else
            @doc_default
          end
        end

        def documented?
          !!docstring
        end

      end
    end
  end
end
