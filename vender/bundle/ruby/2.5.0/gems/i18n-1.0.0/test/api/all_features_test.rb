require 'test_helper'

begin
  require 'rubygems'
  require 'active_support'
rescue LoadError
  puts "not testing with Cache enabled because active_support can not be found"
end

class I18nAllFeaturesApiTest < I18n::TestCase
  class Backend < I18n::Backend::Simple
    include I18n::Backend::Metadata
    include I18n::Backend::Cache
    include I18n::Backend::Cascade
    include I18n::Backend::Fallbacks
    include I18n::Backend::Pluralization
    include I18n::Backend::Memoize
  end

  def setup
    I18n.backend = I18n::Backend::Chain.new(Backend.new, I18n::Backend::Simple.new)
    I18n.cache_store = cache_store
    super
  end

  def teardown
    I18n.cache_store.clear if I18n.cache_store
    I18n.cache_store = nil
    super
  end

  def cache_store
    ActiveSupport::Cache.lookup_store(:memory_store) if cache_available?
  end

  def cache_available?
    defined?(ActiveSupport) && defined?(ActiveSupport::Cache)
  end

  include I18n::Tests::Basics
  include I18n::Tests::Defaults
  include I18n::Tests::Interpolation
  include I18n::Tests::Link
  include I18n::Tests::Lookup
  include I18n::Tests::Pluralization
  include I18n::Tests::Procs
  include I18n::Tests::Localization::Date
  include I18n::Tests::Localization::DateTime
  include I18n::Tests::Localization::Time
  include I18n::Tests::Localization::Procs

  test "make sure we use a Chain backend with an all features backend" do
    assert_equal I18n::Backend::Chain, I18n.backend.class
    assert_equal Backend, I18n.backend.backends.first.class
  end

  # links: test that keys stored on one backend can link to keys stored on another backend
end
