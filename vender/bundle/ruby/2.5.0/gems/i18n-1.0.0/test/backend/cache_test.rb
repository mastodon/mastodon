require 'test_helper'
require 'digest/md5'

begin
  require 'active_support'
rescue LoadError
  $stderr.puts "Skipping cache tests using ActiveSupport"
else

class I18nBackendCacheTest < I18n::TestCase
  class Backend < I18n::Backend::Simple
    include I18n::Backend::Cache
  end

  def setup
    I18n.backend = Backend.new
    super
    I18n.cache_store = ActiveSupport::Cache.lookup_store(:memory_store)
    I18n.cache_key_digest = nil
  end

  def teardown
    super
    I18n.cache_store = nil
  end

  test "it uses the cache" do
    assert I18n.cache_store.is_a?(ActiveSupport::Cache::MemoryStore)
  end

  test "translate hits the backend and caches the response" do
    I18n.backend.expects(:lookup).returns('Foo')
    assert_equal 'Foo', I18n.t(:foo)

    I18n.backend.expects(:lookup).never
    assert_equal 'Foo', I18n.t(:foo)

    I18n.backend.expects(:lookup).returns('Bar')
    assert_equal 'Bar', I18n.t(:bar)
  end

  test "translate returns a cached false response" do
    I18n.backend.expects(:lookup).never
    I18n.cache_store.expects(:read).returns(false)
    assert_equal false, I18n.t(:foo)
  end

  test "still raises MissingTranslationData but also caches it" do
    assert_raise(I18n::MissingTranslationData) { I18n.t(:missing, :raise => true) }
    assert_raise(I18n::MissingTranslationData) { I18n.t(:missing, :raise => true) }
    assert_equal 1, I18n.cache_store.instance_variable_get(:@data).size

    # I18n.backend.expects(:lookup).returns(nil)
    # assert_raise(I18n::MissingTranslationData) { I18n.t(:missing, :raise => true) }
    # I18n.backend.expects(:lookup).never
    # assert_raise(I18n::MissingTranslationData) { I18n.t(:missing, :raise => true) }
  end

  test "uses 'i18n' as a cache key namespace by default" do
    assert_equal 0, I18n.backend.send(:cache_key, :en, :foo, {}).index('i18n')
  end

  test "adds a custom cache key namespace" do
    with_cache_namespace('bar') do
      assert_equal 0, I18n.backend.send(:cache_key, :en, :foo, {}).index('i18n/bar/')
    end
  end

  test "adds locale and hash of key and hash of options" do
    options = { :bar=>1 }
    options_hash = RUBY_VERSION <= "1.9" ? options.inspect.hash : options.hash
    assert_equal "i18n//en/#{:foo.hash}/#{options_hash}", I18n.backend.send(:cache_key, :en, :foo, options)
  end

  test "cache_key uses configured digest method" do
    md5 = Digest::MD5.new
    options = { :bar=>1 }
    options_hash = options.inspect
    with_cache_key_digest(md5) do
      assert_equal "i18n//en/#{md5.hexdigest(:foo.to_s)}/#{md5.hexdigest(options_hash)}", I18n.backend.send(:cache_key, :en, :foo, options)
    end
  end

  test "keys should not be equal" do
    interpolation_values1 = { :foo => 1, :bar => 2 }
    interpolation_values2 = { :foo => 2, :bar => 1 }

    key1 = I18n.backend.send(:cache_key, :en, :some_key, interpolation_values1)
    key2 = I18n.backend.send(:cache_key, :en, :some_key, interpolation_values2)

    assert key1 != key2
  end

  protected

    def with_cache_namespace(namespace)
      I18n.cache_namespace = namespace
      yield
      I18n.cache_namespace = nil
    end

    def with_cache_key_digest(digest)
      I18n.cache_key_digest = digest
      yield
      I18n.cache_key_digest = nil
    end
end

end # AS cache check
