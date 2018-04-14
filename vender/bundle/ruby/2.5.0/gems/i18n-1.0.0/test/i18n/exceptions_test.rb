require 'test_helper'

class I18nExceptionsTest < I18n::TestCase
  def test_invalid_locale_stores_locale
    force_invalid_locale
  rescue I18n::ArgumentError => exception
    assert_nil exception.locale
  end

  test "passing an invalid locale raises an InvalidLocale exception" do
    force_invalid_locale do |exception|
      assert_equal 'nil is not a valid locale', exception.message
    end
  end

  test "MissingTranslation can be initialized without options" do
    exception = I18n::MissingTranslation.new(:en, 'foo')
    assert_equal({}, exception.options)
  end

  test "MissingTranslationData exception stores locale, key and options" do
    force_missing_translation_data do |exception|
      assert_equal 'de', exception.locale
      assert_equal :foo, exception.key
      assert_equal({:scope => :bar}, exception.options)
    end
  end

  test "MissingTranslationData message contains the locale and scoped key" do
    force_missing_translation_data do |exception|
      assert_equal 'translation missing: de.bar.foo', exception.message
    end
  end

  test "InvalidPluralizationData stores entry, count and key" do
    force_invalid_pluralization_data do |exception|
      assert_equal({:other => "bar"}, exception.entry)
      assert_equal 1, exception.count
      assert_equal :one, exception.key
    end
  end

  test "InvalidPluralizationData message contains count, data and missing key" do
    force_invalid_pluralization_data do |exception|
      assert_match '1', exception.message
      assert_match '{:other=>"bar"}', exception.message
      assert_match 'one', exception.message
    end
  end

  test "MissingInterpolationArgument stores key and string" do
    assert_raise(I18n::MissingInterpolationArgument) { force_missing_interpolation_argument }
    force_missing_interpolation_argument do |exception|
      assert_equal :bar, exception.key
      assert_equal "%{bar}", exception.string
    end
  end

  test "MissingInterpolationArgument message contains the missing and given arguments" do
    force_missing_interpolation_argument do |exception|
      assert_equal 'missing interpolation argument :bar in "%{bar}" ({:baz=>"baz"} given)', exception.message
    end
  end

  test "ReservedInterpolationKey stores key and string" do
    force_reserved_interpolation_key do |exception|
      assert_equal :scope, exception.key
      assert_equal "%{scope}", exception.string
    end
  end

  test "ReservedInterpolationKey message contains the reserved key" do
    force_reserved_interpolation_key do |exception|
      assert_equal 'reserved key :scope used in "%{scope}"', exception.message
    end
  end

  test "MissingTranslationData#new can be initialized with just two arguments" do
    assert I18n::MissingTranslationData.new('en', 'key')
  end

  private

    def force_invalid_locale
      I18n.translate(:foo, :locale => nil)
    rescue I18n::ArgumentError => e
      block_given? ? yield(e) : raise(e)
    end

    def force_missing_translation_data(options = {})
      store_translations('de', :bar => nil)
      I18n.translate(:foo, options.merge(:scope => :bar, :locale => :de))
    rescue I18n::ArgumentError => e
      block_given? ? yield(e) : raise(e)
    end

    def force_invalid_pluralization_data
      store_translations('de', :foo => { :other => 'bar' })
      I18n.translate(:foo, :count => 1, :locale => :de)
    rescue I18n::ArgumentError => e
      block_given? ? yield(e) : raise(e)
    end

    def force_missing_interpolation_argument
      store_translations('de', :foo => "%{bar}")
      I18n.translate(:foo, :baz => 'baz', :locale => :de)
    rescue I18n::ArgumentError => e
      block_given? ? yield(e) : raise(e)
    end

    def force_reserved_interpolation_key
      store_translations('de', :foo => "%{scope}")
      I18n.translate(:foo, :baz => 'baz', :locale => :de)
    rescue I18n::ArgumentError => e
      block_given? ? yield(e) : raise(e)
    end
end
