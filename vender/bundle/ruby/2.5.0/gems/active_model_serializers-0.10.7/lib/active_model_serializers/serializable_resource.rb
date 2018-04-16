require 'set'

module ActiveModelSerializers
  class SerializableResource
    ADAPTER_OPTION_KEYS = Set.new([:include, :fields, :adapter, :meta, :meta_key, :links, :serialization_context, :key_transform])
    include ActiveModelSerializers::Logging

    delegate :serializable_hash, :as_json, :to_json, to: :adapter
    notify :serializable_hash, :render
    notify :as_json, :render
    notify :to_json, :render

    # Primary interface to composing a resource with a serializer and adapter.
    # @return the serializable_resource, ready for #as_json/#to_json/#serializable_hash.
    def initialize(resource, options = {})
      @resource = resource
      @adapter_opts, @serializer_opts =
        options.partition { |k, _| ADAPTER_OPTION_KEYS.include? k }.map { |h| Hash[h] }
    end

    def serialization_scope=(scope)
      serializer_opts[:scope] = scope
    end

    def serialization_scope
      serializer_opts[:scope]
    end

    def serialization_scope_name=(scope_name)
      serializer_opts[:scope_name] = scope_name
    end

    # NOTE: if no adapter is available, returns the resource itself. (i.e. adapter is a no-op)
    def adapter
      @adapter ||= find_adapter
    end
    alias adapter_instance adapter

    def find_adapter
      return resource unless serializer?
      adapter = catch :no_serializer do
        ActiveModelSerializers::Adapter.create(serializer_instance, adapter_opts)
      end
      adapter || resource
    end

    def serializer_instance
      @serializer_instance ||= serializer.new(resource, serializer_opts)
    end

    # Get serializer either explicitly :serializer or implicitly from resource
    # Remove :serializer key from serializer_opts
    # Remove :each_serializer if present and set as :serializer key
    def serializer
      @serializer ||=
        begin
          @serializer = serializer_opts.delete(:serializer)
          @serializer ||= ActiveModel::Serializer.serializer_for(resource, serializer_opts)

          if serializer_opts.key?(:each_serializer)
            serializer_opts[:serializer] = serializer_opts.delete(:each_serializer)
          end
          @serializer
        end
    end
    alias serializer_class serializer

    # True when no explicit adapter given, or explicit appear is truthy (non-nil)
    # False when explicit adapter is falsy (nil or false)
    def use_adapter?
      !(adapter_opts.key?(:adapter) && !adapter_opts[:adapter])
    end

    def serializer?
      use_adapter? && !serializer.nil?
    end

    protected

    attr_reader :resource, :adapter_opts, :serializer_opts
  end
end
