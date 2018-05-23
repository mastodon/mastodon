require 'test_helper'

class I18nMemoizeBackendWithSimpleApiTest < I18n::TestCase
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

  class MemoizeBackend < I18n::Backend::Simple
    include I18n::Backend::Memoize
  end

  def setup
    I18n.backend = MemoizeBackend.new
    super
  end

  test "make sure we use the MemoizeBackend backend" do
    assert_equal MemoizeBackend, I18n.backend.class
  end
end

class I18nMemoizeBackendWithKeyValueApiTest < I18n::TestCase
  include I18n::Tests::Basics
  include I18n::Tests::Defaults
  include I18n::Tests::Interpolation
  include I18n::Tests::Link
  include I18n::Tests::Lookup
  include I18n::Tests::Pluralization
  include I18n::Tests::Localization::Date
  include I18n::Tests::Localization::DateTime
  include I18n::Tests::Localization::Time

  # include I18n::Tests::Procs
  # include I18n::Tests::Localization::Procs

  class MemoizeBackend < I18n::Backend::KeyValue
    include I18n::Backend::Memoize
  end

  def setup
    I18n.backend = MemoizeBackend.new({})
    super
  end

  test "make sure we use the MemoizeBackend backend" do
    assert_equal MemoizeBackend, I18n.backend.class
  end
end if I18n::TestCase.key_value?
