require 'test_helper'

class I18nCascadeApiTest < I18n::TestCase
  class Backend < I18n::Backend::Simple
    include I18n::Backend::Cascade
  end

  def setup
    I18n.backend = Backend.new
    super
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

  test "make sure we use a backend with Cascade included" do
    assert_equal Backend, I18n.backend.class
  end
end
