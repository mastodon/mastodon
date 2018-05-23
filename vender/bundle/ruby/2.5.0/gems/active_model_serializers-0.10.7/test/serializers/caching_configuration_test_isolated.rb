# Execute this test in isolation
require 'support/isolated_unit'

class CachingConfigurationTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::Isolation

  setup do
    require 'rails'
    # AMS needs to be required before Rails.application is initialized for
    # Railtie's to fire in Rails.application.initialize!
    # (and make_basic_app initializes the app)
    require 'active_model_serializers'
    # Create serializers before Rails.application.initialize!
    # To ensure we're testing that the cache settings depend on
    # the Railtie firing, not on the ActionController being loaded.
    create_serializers
  end

  def create_serializers
    @cached_serializer = Class.new(ActiveModel::Serializer) do
      cache skip_digest: true
      attributes :id, :name, :title
    end
    @fragment_cached_serializer = Class.new(ActiveModel::Serializer) do
      cache only: :id
      attributes :id, :name, :title
    end
    @non_cached_serializer = Class.new(ActiveModel::Serializer) do
      attributes :id, :name, :title
    end
  end

  class PerformCachingTrue < CachingConfigurationTest
    setup do
      # Let's make that Rails app and initialize it!
      make_basic_app do |app|
        app.config.action_controller.perform_caching = true
        app.config.action_controller.cache_store = ActiveSupport::Cache.lookup_store(:memory_store)
      end
      controller_cache_store # Force ActiveSupport.on_load(:action_controller) to run
    end

    test 'it sets perform_caching to true on AMS.config and serializers' do
      assert Rails.configuration.action_controller.perform_caching
      assert ActiveModelSerializers.config.perform_caching
      assert ActiveModel::Serializer.perform_caching?
      assert @cached_serializer.perform_caching?
      assert @non_cached_serializer.perform_caching?
      assert @fragment_cached_serializer.perform_caching?
    end

    test 'it sets the AMS.config.cache_store to the controller cache_store' do
      assert_equal controller_cache_store, ActiveSupport::Cache::MemoryStore
      assert_equal controller_cache_store, ActiveModelSerializers.config.cache_store.class
    end

    test 'it sets the cached serializer cache_store to the ActionController::Base.cache_store' do
      assert_equal ActiveSupport::Cache::NullStore, @cached_serializer._cache.class
      assert_equal controller_cache_store, @cached_serializer.cache_store.class
      assert_equal ActiveSupport::Cache::MemoryStore, @cached_serializer._cache.class
    end

    test 'the cached serializer has cache_enabled?' do
      assert @cached_serializer.cache_enabled?
    end

    test 'the cached serializer does not have fragment_cache_enabled?' do
      refute @cached_serializer.fragment_cache_enabled?
    end

    test 'the non-cached serializer cache_store is nil' do
      assert_nil @non_cached_serializer._cache
      assert_nil @non_cached_serializer.cache_store
      assert_nil @non_cached_serializer._cache
    end

    test 'the non-cached serializer does not have cache_enabled?' do
      refute @non_cached_serializer.cache_enabled?
    end

    test 'the non-cached serializer does not have fragment_cache_enabled?' do
      refute @non_cached_serializer.fragment_cache_enabled?
    end

    test 'it sets the fragment cached serializer cache_store to the ActionController::Base.cache_store' do
      assert_equal ActiveSupport::Cache::NullStore, @fragment_cached_serializer._cache.class
      assert_equal controller_cache_store, @fragment_cached_serializer.cache_store.class
      assert_equal ActiveSupport::Cache::MemoryStore, @fragment_cached_serializer._cache.class
    end

    test 'the fragment cached serializer does not have cache_enabled?' do
      refute @fragment_cached_serializer.cache_enabled?
    end

    test 'the fragment cached serializer has fragment_cache_enabled?' do
      assert @fragment_cached_serializer.fragment_cache_enabled?
    end
  end

  class PerformCachingFalse < CachingConfigurationTest
    setup do
      # Let's make that Rails app and initialize it!
      make_basic_app do |app|
        app.config.action_controller.perform_caching = false
        app.config.action_controller.cache_store = ActiveSupport::Cache.lookup_store(:memory_store)
      end
      controller_cache_store # Force ActiveSupport.on_load(:action_controller) to run
    end

    test 'it sets perform_caching to false on AMS.config and serializers' do
      refute Rails.configuration.action_controller.perform_caching
      refute ActiveModelSerializers.config.perform_caching
      refute ActiveModel::Serializer.perform_caching?
      refute @cached_serializer.perform_caching?
      refute @non_cached_serializer.perform_caching?
      refute @fragment_cached_serializer.perform_caching?
    end

    test 'it sets the AMS.config.cache_store to the controller cache_store' do
      assert_equal controller_cache_store, ActiveSupport::Cache::MemoryStore
      assert_equal controller_cache_store, ActiveModelSerializers.config.cache_store.class
    end

    test 'it sets the cached serializer cache_store to the ActionController::Base.cache_store' do
      assert_equal ActiveSupport::Cache::NullStore, @cached_serializer._cache.class
      assert_equal controller_cache_store, @cached_serializer.cache_store.class
      assert_equal ActiveSupport::Cache::MemoryStore, @cached_serializer._cache.class
    end

    test 'the cached serializer does not have cache_enabled?' do
      refute @cached_serializer.cache_enabled?
    end

    test 'the cached serializer does not have fragment_cache_enabled?' do
      refute @cached_serializer.fragment_cache_enabled?
    end

    test 'the non-cached serializer cache_store is nil' do
      assert_nil @non_cached_serializer._cache
      assert_nil @non_cached_serializer.cache_store
      assert_nil @non_cached_serializer._cache
    end

    test 'the non-cached serializer does not have cache_enabled?' do
      refute @non_cached_serializer.cache_enabled?
    end

    test 'the non-cached serializer does not have fragment_cache_enabled?' do
      refute @non_cached_serializer.fragment_cache_enabled?
    end

    test 'it sets the fragment cached serializer cache_store to the ActionController::Base.cache_store' do
      assert_equal ActiveSupport::Cache::NullStore, @fragment_cached_serializer._cache.class
      assert_equal controller_cache_store, @fragment_cached_serializer.cache_store.class
      assert_equal ActiveSupport::Cache::MemoryStore, @fragment_cached_serializer._cache.class
    end

    test 'the fragment cached serializer does not have cache_enabled?' do
      refute @fragment_cached_serializer.cache_enabled?
    end

    test 'the fragment cached serializer does not have fragment_cache_enabled?' do
      refute @fragment_cached_serializer.fragment_cache_enabled?
    end
  end

  def controller_cache_store
    ActionController::Base.cache_store.class
  end
end
