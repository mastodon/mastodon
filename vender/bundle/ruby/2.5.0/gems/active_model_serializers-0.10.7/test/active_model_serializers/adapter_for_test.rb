require 'test_helper'

module ActiveModelSerializers
  class AdapterForTest < ::ActiveSupport::TestCase
    UnknownAdapterError = ::ActiveModelSerializers::Adapter::UnknownAdapterError

    def test_serializer_adapter_returns_configured_adapter
      assert_output(nil, /ActiveModelSerializers::Adapter.configured_adapter/) do
        assert_equal ActiveModelSerializers::Adapter.configured_adapter, ActiveModel::Serializer.adapter
      end
    end

    def test_returns_default_adapter
      with_adapter_config_setup do
        adapter = ActiveModelSerializers::Adapter.configured_adapter
        assert_equal ActiveModelSerializers::Adapter::Attributes, adapter
      end
    end

    def test_overwrite_adapter_with_symbol
      with_adapter_config_setup do
        ActiveModelSerializers.config.adapter = :null

        adapter = ActiveModelSerializers::Adapter.configured_adapter
        assert_equal ActiveModelSerializers::Adapter::Null, adapter
      end
    end

    def test_overwrite_adapter_with_camelcased_symbol
      with_adapter_config_setup do
        ActiveModelSerializers.config.adapter = :JsonApi

        adapter = ActiveModelSerializers::Adapter.configured_adapter
        assert_equal ActiveModelSerializers::Adapter::JsonApi, adapter
      end
    end

    def test_overwrite_adapter_with_string
      with_adapter_config_setup do
        ActiveModelSerializers.config.adapter = 'json_api'

        adapter = ActiveModelSerializers::Adapter.configured_adapter
        assert_equal ActiveModelSerializers::Adapter::JsonApi, adapter
      end
    end

    def test_overwrite_adapter_with_a_camelcased_string
      with_adapter_config_setup do
        ActiveModelSerializers.config.adapter = 'JsonApi'

        adapter = ActiveModelSerializers::Adapter.configured_adapter
        assert_equal ActiveModelSerializers::Adapter::JsonApi, adapter
      end
    end

    def test_overwrite_adapter_with_class
      with_adapter_config_setup do
        ActiveModelSerializers.config.adapter = ActiveModelSerializers::Adapter::Null

        adapter = ActiveModelSerializers::Adapter.configured_adapter
        assert_equal ActiveModelSerializers::Adapter::Null, adapter
      end
    end

    def test_raises_exception_if_invalid_symbol_given
      with_adapter_config_setup do
        ActiveModelSerializers.config.adapter = :unknown

        assert_raises UnknownAdapterError do
          ActiveModelSerializers::Adapter.configured_adapter
        end
      end
    end

    def test_raises_exception_if_it_does_not_know_hot_to_infer_adapter
      with_adapter_config_setup do
        ActiveModelSerializers.config.adapter = 42

        assert_raises UnknownAdapterError do
          ActiveModelSerializers::Adapter.configured_adapter
        end
      end
    end

    def test_adapter_class_for_known_adapter
      klass = ActiveModelSerializers::Adapter.adapter_class(:json_api)
      assert_equal ActiveModelSerializers::Adapter::JsonApi, klass
    end

    def test_adapter_class_for_unknown_adapter
      assert_raises UnknownAdapterError do
        ActiveModelSerializers::Adapter.adapter_class(:json_simple)
      end
    end

    def test_adapter_map
      expected_adapter_map = {
        'null'.freeze              => ActiveModelSerializers::Adapter::Null,
        'json'.freeze              => ActiveModelSerializers::Adapter::Json,
        'attributes'.freeze => ActiveModelSerializers::Adapter::Attributes,
        'json_api'.freeze => ActiveModelSerializers::Adapter::JsonApi
      }
      actual = ActiveModelSerializers::Adapter.adapter_map
      assert_equal actual, expected_adapter_map
    end

    def test_adapters
      assert_equal ActiveModelSerializers::Adapter.adapters.sort, [
        'attributes'.freeze,
        'json'.freeze,
        'json_api'.freeze,
        'null'.freeze
      ]
    end

    def test_lookup_adapter_by_string_name
      assert_equal ActiveModelSerializers::Adapter.lookup('json'.freeze), ActiveModelSerializers::Adapter::Json
    end

    def test_lookup_adapter_by_symbol_name
      assert_equal ActiveModelSerializers::Adapter.lookup(:json), ActiveModelSerializers::Adapter::Json
    end

    def test_lookup_adapter_by_class
      klass = ActiveModelSerializers::Adapter::Json
      assert_equal ActiveModelSerializers::Adapter.lookup(klass), klass
    end

    def test_lookup_adapter_from_environment_registers_adapter
      ActiveModelSerializers::Adapter.const_set(:AdapterFromEnvironment, Class.new)
      klass = ::ActiveModelSerializers::Adapter::AdapterFromEnvironment
      name = 'adapter_from_environment'.freeze
      assert_equal ActiveModelSerializers::Adapter.lookup(name), klass
      assert ActiveModelSerializers::Adapter.adapters.include?(name)
    ensure
      ActiveModelSerializers::Adapter.adapter_map.delete(name)
      ActiveModelSerializers::Adapter.send(:remove_const, :AdapterFromEnvironment)
    end

    def test_lookup_adapter_for_unknown_name
      assert_raises UnknownAdapterError do
        ActiveModelSerializers::Adapter.lookup(:json_simple)
      end
    end

    def test_adapter
      assert_equal ActiveModelSerializers.config.adapter, :attributes
      assert_equal ActiveModelSerializers::Adapter.configured_adapter, ActiveModelSerializers::Adapter::Attributes
    end

    def test_register_adapter
      new_adapter_name  = :foo
      new_adapter_klass = Class.new
      ActiveModelSerializers::Adapter.register(new_adapter_name, new_adapter_klass)
      assert ActiveModelSerializers::Adapter.adapters.include?('foo'.freeze)
      assert ActiveModelSerializers::Adapter.lookup(:foo), new_adapter_klass
    ensure
      ActiveModelSerializers::Adapter.adapter_map.delete(new_adapter_name.to_s)
    end

    def test_inherited_adapter_hooks_register_adapter
      Object.const_set(:MyAdapter, Class.new)
      my_adapter = MyAdapter
      ActiveModelSerializers::Adapter::Base.inherited(my_adapter)
      assert_equal ActiveModelSerializers::Adapter.lookup(:my_adapter), my_adapter
    ensure
      ActiveModelSerializers::Adapter.adapter_map.delete('my_adapter'.freeze)
      Object.send(:remove_const, :MyAdapter)
    end

    def test_inherited_adapter_hooks_register_namespaced_adapter
      Object.const_set(:MyNamespace, Module.new)
      MyNamespace.const_set(:MyAdapter, Class.new)
      my_adapter = MyNamespace::MyAdapter
      ActiveModelSerializers::Adapter::Base.inherited(my_adapter)
      assert_equal ActiveModelSerializers::Adapter.lookup(:'my_namespace/my_adapter'), my_adapter
    ensure
      ActiveModelSerializers::Adapter.adapter_map.delete('my_namespace/my_adapter'.freeze)
      MyNamespace.send(:remove_const, :MyAdapter)
      Object.send(:remove_const, :MyNamespace)
    end

    def test_inherited_adapter_hooks_register_subclass_of_registered_adapter
      Object.const_set(:MyAdapter, Class.new)
      my_adapter = MyAdapter
      Object.const_set(:MySubclassedAdapter, Class.new(MyAdapter))
      my_subclassed_adapter = MySubclassedAdapter
      ActiveModelSerializers::Adapter::Base.inherited(my_adapter)
      ActiveModelSerializers::Adapter::Base.inherited(my_subclassed_adapter)
      assert_equal ActiveModelSerializers::Adapter.lookup(:my_adapter), my_adapter
      assert_equal ActiveModelSerializers::Adapter.lookup(:my_subclassed_adapter), my_subclassed_adapter
    ensure
      ActiveModelSerializers::Adapter.adapter_map.delete('my_adapter'.freeze)
      ActiveModelSerializers::Adapter.adapter_map.delete('my_subclassed_adapter'.freeze)
      Object.send(:remove_const, :MyAdapter)
      Object.send(:remove_const, :MySubclassedAdapter)
    end

    private

    def with_adapter_config_setup
      previous_adapter = ActiveModelSerializers.config.adapter
      yield
    ensure
      ActiveModelSerializers.config.adapter = previous_adapter
    end
  end
end
