require 'test_helper'

class I18nBackendFallbacksTranslateTest < I18n::TestCase
  class Backend < I18n::Backend::Simple
    include I18n::Backend::Fallbacks
  end

  def setup
    super
    I18n.backend = Backend.new
    store_translations(:en, :foo => 'Foo in :en', :bar => 'Bar in :en', :buz => 'Buz in :en', :interpolate => 'Interpolate %{value}')
    store_translations(:de, :bar => 'Bar in :de', :baz => 'Baz in :de')
    store_translations(:'de-DE', :baz => 'Baz in :de-DE')
    store_translations(:'pt-BR', :baz => 'Baz in :pt-BR')
  end

  test "still returns an existing translation as usual" do
    assert_equal 'Foo in :en', I18n.t(:foo, :locale => :en)
    assert_equal 'Bar in :de', I18n.t(:bar, :locale => :de)
    assert_equal 'Baz in :de-DE', I18n.t(:baz, :locale => :'de-DE')
  end

  test "returns interpolated value if no key provided" do
    assert_equal 'Interpolate %{value}', I18n.t(:interpolate)
  end

  test "returns the :en translation for a missing :de translation" do
    assert_equal 'Foo in :en', I18n.t(:foo, :locale => :de)
  end

  test "returns the :de translation for a missing :'de-DE' translation" do
    assert_equal 'Bar in :de', I18n.t(:bar, :locale => :'de-DE')
  end

  test "returns the :en translation for translation missing in both :de and :'de-De'" do
    assert_equal 'Buz in :en', I18n.t(:buz, :locale => :'de-DE')
  end

  test "returns the :de translation for a missing :'de-DE' when :default is a String" do
    assert_equal 'Bar in :de', I18n.t(:bar, :locale => :'de-DE', :default => "Default Bar")
    assert_equal "Default Bar", I18n.t(:missing_bar, :locale => :'de-DE', :default => "Default Bar")
  end

  test "returns the :de translation for a missing :'de-DE' when defaults is a Symbol (which exists in :en)" do
    assert_equal "Bar in :de", I18n.t(:bar, :locale => :'de-DE', :default => [:buz])
  end

  test "returns the :'de-DE' default :baz translation for a missing :'de-DE' (which exists in :de)" do
    assert_equal "Baz in :de-DE", I18n.t(:bar, :locale => :'de-DE', :default => [:baz])
  end

  test "returns the :de translation for a missing :'de-DE' when :default is a Proc" do
    assert_equal 'Bar in :de', I18n.t(:bar, :locale => :'de-DE', :default => Proc.new { "Default Bar" })
    assert_equal "Default Bar", I18n.t(:missing_bar, :locale => :'de-DE', :default => Proc.new { "Default Bar" })
  end

  test "returns the :de translation for a missing :'de-DE' when :default is a Hash" do
    assert_equal 'Bar in :de', I18n.t(:bar, :locale => :'de-DE', :default => {})
    assert_equal({}, I18n.t(:missing_bar, :locale => :'de-DE', :default => {}))
  end

  test "returns the :de translation for a missing :'de-DE' when :default is nil" do
    assert_equal 'Bar in :de', I18n.t(:bar, :locale => :'de-DE', :default => nil)
    assert_nil I18n.t(:missing_bar, :locale => :'de-DE', :default => nil)
  end

  test "returns the translation missing message if the default is also missing" do
    assert_equal 'translation missing: de-DE.missing_bar', I18n.t(:missing_bar, :locale => :'de-DE', :default => [:missing_baz])
  end

  test "returns the :'de-DE' default :baz translation for a missing :'de-DE' when defaults contains Symbol" do
    assert_equal 'Baz in :de-DE', I18n.t(:missing_foo, :locale => :'de-DE', :default => [:baz, "Default Bar"])
  end

  test "returns the defaults translation for a missing :'de-DE' when defaults contains a String or Proc before Symbol" do
    assert_equal "Default Bar", I18n.t(:missing_foo, :locale => :'de-DE', :default => [:missing_bar, "Default Bar", :baz])
    assert_equal "Default Bar", I18n.t(:missing_foo, :locale => :'de-DE', :default => [:missing_bar, Proc.new { "Default Bar" }, :baz])
  end

  test "returns the default translation for a missing :'de-DE' and existing :de when default is a Hash" do
    assert_equal 'Default 6 Bars', I18n.t(:missing_foo, :locale => :'de-DE', :default => [:missing_bar, {:other => "Default %{count} Bars"}, "Default Bar"], :count => 6)
  end

  test "returns the default translation for a missing :de translation even when default is a String when fallback is disabled" do
    assert_equal 'Default String', I18n.t(:foo, :locale => :de, :default => 'Default String', :fallback => false)
  end

  test "raises I18n::MissingTranslationData exception when fallback is disabled even when fallback translation exists" do
    assert_raise(I18n::MissingTranslationData) { I18n.t(:foo, :locale => :de, :fallback => false, :raise => true) }
  end

  test "raises I18n::MissingTranslationData exception when no translation was found" do
    assert_raise(I18n::MissingTranslationData) { I18n.t(:faa, :locale => :en, :raise => true) }
    assert_raise(I18n::MissingTranslationData) { I18n.t(:faa, :locale => :de, :raise => true) }
  end

  test "should ensure that default is not splitted on new line char" do
    assert_equal "Default \n Bar", I18n.t(:missing_bar, :default => "Default \n Bar")
  end

  test "should not raise error when enforce_available_locales is true, :'pt' is missing and default is a Symbol" do
    I18n.enforce_available_locales = true
    begin
      assert_equal 'Foo', I18n.t(:'model.attrs.foo', :locale => :'pt-BR', :default => [:'attrs.foo', "Foo"])
    ensure
      I18n.enforce_available_locales = false
    end
  end
end

class I18nBackendFallbacksLocalizeTest < I18n::TestCase
  class Backend < I18n::Backend::Simple
    include I18n::Backend::Fallbacks
  end

  def setup
    super
    I18n.backend = Backend.new
    store_translations(:en, :date => { :formats => { :en => 'en' }, :day_names => %w(Sunday) })
    store_translations(:de, :date => { :formats => { :de => 'de' } })
  end

  test "still uses an existing format as usual" do
    assert_equal 'en', I18n.l(Date.today, :format => :en, :locale => :en)
  end

  test "looks up and uses a fallback locale's format for a key missing in the given locale (1)" do
    assert_equal 'en', I18n.l(Date.today, :format => :en, :locale => :de)
  end

  test "looks up and uses a fallback locale's format for a key missing in the given locale (2)" do
    assert_equal 'de', I18n.l(Date.today, :format => :de, :locale => :'de-DE')
  end

  test "still uses an existing day name translation as usual" do
    assert_equal 'Sunday', I18n.l(Date.new(2010, 1, 3), :format => '%A', :locale => :en)
  end

  test "uses a fallback locale's translation for a key missing in the given locale" do
    assert_equal 'Sunday', I18n.l(Date.new(2010, 1, 3), :format => '%A', :locale => :de)
  end
end

class I18nBackendFallbacksWithChainTest < I18n::TestCase
  class Backend < I18n::Backend::Simple
    include I18n::Backend::Fallbacks
  end

  class Chain < I18n::Backend::Chain
    include I18n::Backend::Fallbacks
  end

  def setup
    super
    backend = Backend.new
    backend.store_translations(:de, :foo => 'FOO')
    backend.store_translations(:'pt-BR', :foo => 'Baz in :pt-BR')
    I18n.backend = Chain.new(I18n::Backend::Simple.new, backend)
  end

  test "falls back from de-DE to de when there is no translation for de-DE available" do
    assert_equal 'FOO', I18n.t(:foo, :locale => :'de-DE')
  end

  test "falls back from de-DE to de when there is no translation for de-DE available when using arrays, too" do
    assert_equal ['FOO', 'FOO'], I18n.t([:foo, :foo], :locale => :'de-DE')
  end

  test "should not raise error when enforce_available_locales is true, :'pt' is missing and default is a Symbol" do
    I18n.enforce_available_locales = true
    begin
      assert_equal 'Foo', I18n.t(:'model.attrs.foo', :locale => :'pt-BR', :default => [:'attrs.foo', "Foo"])
    ensure
      I18n.enforce_available_locales = false
    end
  end
end

class I18nBackendFallbacksExistsTest < I18n::TestCase
  class Backend < I18n::Backend::Simple
    include I18n::Backend::Fallbacks
  end

  def setup
    super
    I18n.backend = Backend.new
    store_translations(:en, :foo => 'Foo in :en', :bar => 'Bar in :en')
    store_translations(:de, :bar => 'Bar in :de')
    store_translations(:'de-DE', :baz => 'Baz in :de-DE')
  end

  test "exists? given an existing key will return true" do
    assert_equal true, I18n.exists?(:foo)
  end

  test "exists? given a non-existing key will return false" do
    assert_equal false, I18n.exists?(:bogus)
  end

  test "exists? given an existing key and an existing locale will return true" do
    assert_equal true, I18n.exists?(:foo, :en)
    assert_equal true, I18n.exists?(:bar, :de)
  end

  test "exists? given a non-existing key and an existing locale will return false" do
    assert_equal false, I18n.exists?(:bogus, :en)
    assert_equal false, I18n.exists?(:bogus, :de)
  end

  test "exists? should return true given a key which is missing from the given locale and exists in a fallback locale" do
    assert_equal true, I18n.exists?(:foo, :de)
    assert_equal true, I18n.exists?(:foo, :'de-DE')
  end

  test "exists? should return false given a key which is missing from the given locale and all its fallback locales" do
    assert_equal false, I18n.exists?(:baz, :de)
    assert_equal false, I18n.exists?(:bogus, :'de-DE')
  end
end
