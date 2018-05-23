module ActiveModelSerializers
  module Adapter
    UnknownAdapterError = Class.new(ArgumentError)
    ADAPTER_MAP = {} # rubocop:disable Style/MutableConstant
    private_constant :ADAPTER_MAP if defined?(private_constant)

    class << self # All methods are class functions
      # :nocov:
      def new(*args)
        fail ArgumentError, 'Adapters inherit from Adapter::Base.' \
          "Adapter.new called with args: '#{args.inspect}', from" \
          "'caller[0]'."
      end
      # :nocov:

      def configured_adapter
        lookup(ActiveModelSerializers.config.adapter)
      end

      def create(resource, options = {})
        override = options.delete(:adapter)
        klass = override ? adapter_class(override) : configured_adapter
        klass.new(resource, options)
      end

      # @see ActiveModelSerializers::Adapter.lookup
      def adapter_class(adapter)
        ActiveModelSerializers::Adapter.lookup(adapter)
      end

      # @return [Hash<adapter_name, adapter_class>]
      def adapter_map
        ADAPTER_MAP
      end

      # @return [Array<Symbol>] list of adapter names
      def adapters
        adapter_map.keys.sort
      end

      # Adds an adapter 'klass' with 'name' to the 'adapter_map'
      # Names are stringified and underscored
      # @param name [Symbol, String, Class] name of the registered adapter
      # @param klass [Class] adapter class itself, optional if name is the class
      # @example
      #     AMS::Adapter.register(:my_adapter, MyAdapter)
      # @note The registered name strips out 'ActiveModelSerializers::Adapter::'
      #   so that registering 'ActiveModelSerializers::Adapter::Json' and
      #   'Json' will both register as 'json'.
      def register(name, klass = name)
        name = name.to_s.gsub(/\AActiveModelSerializers::Adapter::/, ''.freeze)
        adapter_map[name.underscore] = klass
        self
      end

      def registered_name(adapter_class)
        ADAPTER_MAP.key adapter_class
      end

      # @param  adapter [String, Symbol, Class] name to fetch adapter by
      # @return [ActiveModelSerializers::Adapter] subclass of Adapter
      # @raise  [UnknownAdapterError]
      def lookup(adapter)
        # 1. return if is a class
        return adapter if adapter.is_a?(Class)
        adapter_name = adapter.to_s.underscore
        # 2. return if registered
        adapter_map.fetch(adapter_name) do
          # 3. try to find adapter class from environment
          adapter_class = find_by_name(adapter_name)
          register(adapter_name, adapter_class)
          adapter_class
        end
      rescue NameError, ArgumentError => e
        failure_message =
          "NameError: #{e.message}. Unknown adapter: #{adapter.inspect}. Valid adapters are: #{adapters}"
        raise UnknownAdapterError, failure_message, e.backtrace
      end

      # @api private
      def find_by_name(adapter_name)
        adapter_name = adapter_name.to_s.classify.tr('API', 'Api')
        "ActiveModelSerializers::Adapter::#{adapter_name}".safe_constantize ||
          "ActiveModelSerializers::Adapter::#{adapter_name.pluralize}".safe_constantize or # rubocop:disable Style/AndOr
          fail UnknownAdapterError
      end
      private :find_by_name
    end

    # Gotta be at the bottom to use the code above it :(
    extend ActiveSupport::Autoload
    autoload :Base
    autoload :Null
    autoload :Attributes
    autoload :Json
    autoload :JsonApi
  end
end
