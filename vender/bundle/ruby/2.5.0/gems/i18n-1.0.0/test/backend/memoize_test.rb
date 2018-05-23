require 'test_helper'
# TODO: change back to "require 'backend/simple'" when dropping support to Ruby 1.8.7.
require File.expand_path('../simple_test', __FILE__)

class I18nBackendMemoizeTest < I18nBackendSimpleTest
  module MemoizeSpy
    attr_accessor :spy_calls

    def available_locales
      self.spy_calls = (self.spy_calls || 0) + 1
      super
    end
  end

  class MemoizeBackend < I18n::Backend::Simple
    include MemoizeSpy
    include I18n::Backend::Memoize
  end

  def setup
    super
    I18n.backend = MemoizeBackend.new
  end

  def test_memoizes_available_locales
    I18n.backend.spy_calls = 0
    assert_equal I18n.available_locales, I18n.available_locales
    assert_equal 1, I18n.backend.spy_calls
  end

  def test_resets_available_locales_on_reload!
    I18n.available_locales
    I18n.backend.spy_calls = 0
    I18n.reload!
    assert_equal I18n.available_locales, I18n.available_locales
    assert_equal 1, I18n.backend.spy_calls
  end

  def test_resets_available_locales_on_store_translations
    I18n.available_locales
    I18n.backend.spy_calls = 0
    I18n.backend.store_translations(:copa, :ca => :bana)
    assert_equal I18n.available_locales, I18n.available_locales
    assert I18n.available_locales.include?(:copa)
    assert_equal 1, I18n.backend.spy_calls
  end

  module TestLookup
    def lookup(locale, key, scope = [], options = {})
      keys = I18n.normalize_keys(locale, key, scope, options[:separator])
      keys.inspect
    end
  end

  def test_lookup_concurrent_consistency
    backend_impl = Class.new(I18n::Backend::Simple) do
      include TestLookup
      include I18n::Backend::Memoize
    end
    backend = backend_impl.new

    memoized_lookup = backend.send(:memoized_lookup)

    assert_equal "[:foo, :scoped, :sample]", backend.translate('foo', scope = [:scoped, :sample])

    results = []
    30.times.inject([]) do |memo, i|
      memo << Thread.new do
        backend.translate('bar', scope); backend.translate(:baz, scope)
      end
    end.each(&:join)

    memoized_lookup = backend.send(:memoized_lookup)
    puts memoized_lookup.inspect if $VERBOSE
    assert_equal 3, memoized_lookup.size, "NON-THREAD-SAFE lookup memoization backend: #{memoized_lookup.class}"
    # if a plain Hash is used might eventually end up in a weird (inconsistent) state
  end

end
