module SerializationTesting
  def config
    ActiveModelSerializers.config
  end

  private

  def generate_cached_serializer(obj)
    ActiveModelSerializers::SerializableResource.new(obj).to_json
  end

  def with_namespace_separator(separator)
    original_separator = ActiveModelSerializers.config.jsonapi_namespace_separator
    ActiveModelSerializers.config.jsonapi_namespace_separator = separator
    yield
  ensure
    ActiveModelSerializers.config.jsonapi_namespace_separator = original_separator
  end

  def with_prepended_lookup(lookup_proc)
    original_lookup = ActiveModelSerializers.config.serializer_lookup_cahin
    ActiveModelSerializers.config.serializer_lookup_chain.unshift lookup_proc
    yield
  ensure
    ActiveModelSerializers.config.serializer_lookup_cahin = original_lookup
  end

  # Aliased as :with_configured_adapter to clarify that
  # this method tests the configured adapter.
  # When not testing configuration, it may be preferable
  # to pass in the +adapter+ option to <tt>ActiveModelSerializers::SerializableResource</tt>.
  # e.g ActiveModelSerializers::SerializableResource.new(resource, adapter: :json_api)
  def with_adapter(adapter)
    old_adapter = ActiveModelSerializers.config.adapter
    ActiveModelSerializers.config.adapter = adapter
    yield
  ensure
    ActiveModelSerializers.config.adapter = old_adapter
  end
  alias with_configured_adapter with_adapter

  def with_config(hash)
    old_config = config.dup
    ActiveModelSerializers.config.update(hash)
    yield
  ensure
    ActiveModelSerializers.config.replace(old_config)
  end

  def with_jsonapi_inflection(inflection)
    original_inflection = ActiveModelSerializers.config.jsonapi_resource_type
    ActiveModelSerializers.config.jsonapi_resource_type = inflection
    yield
  ensure
    ActiveModelSerializers.config.jsonapi_resource_type = original_inflection
  end

  def with_serializer_lookup_disabled
    original_serializer_lookup = ActiveModelSerializers.config.serializer_lookup_enabled
    ActiveModelSerializers.config.serializer_lookup_enabled = false
    yield
  ensure
    ActiveModelSerializers.config.serializer_lookup_enabled = original_serializer_lookup
  end

  def serializable(resource, options = {})
    ActiveModelSerializers::SerializableResource.new(resource, options)
  end
end

module Minitest
  class Test
    def before_setup
      ActionController::Base.cache_store.clear
    end

    include SerializationTesting
  end
end
