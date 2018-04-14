require 'test_helper'

class I18nGettextPluralKeysTest < I18n::TestCase
  def setup
    super
    I18n::Gettext.plural_keys[:zz] = [:value1, :value2]
  end

  test "Returns the plural keys of the given locale if present" do
    assert_equal I18n::Gettext.plural_keys(:zz), [:value1, :value2]
  end

  test "Returns the plural keys of :en if given locale not present" do
    assert_equal I18n::Gettext.plural_keys(:yy), [:one, :other]
  end

  test "Returns the whole hash with no arguments" do
    assert_equal I18n::Gettext.plural_keys, { :en => [:one, :other], :zz => [:value1, :value2] }
  end
end
