require 'test_helper'

class I18nBackendExceptionsTest < I18n::TestCase
  def setup
    super
    I18n.backend = I18n::Backend::Simple.new
  end

  test "throw message: MissingTranslation message from #translate includes the given scope and full key" do
    exception = catch(:exception) do
      I18n.t(:'baz.missing', :scope => :'foo.bar', :throw => true)
    end
    assert_equal "translation missing: en.foo.bar.baz.missing", exception.message
  end

  test "exceptions: MissingTranslationData message from #translate includes the given scope and full key" do
    begin
      I18n.t(:'baz.missing', :scope => :'foo.bar', :raise => true)
    rescue I18n::MissingTranslationData => exception
    end
    assert_equal "translation missing: en.foo.bar.baz.missing", exception.message
  end

  test "exceptions: MissingTranslationData message from #localize includes the given scope and full key" do
    begin
      I18n.l(Time.now, :format => :foo)
    rescue I18n::MissingTranslationData => exception
    end
    assert_equal "translation missing: en.time.formats.foo", exception.message
  end

  test "exceptions: MissingInterpolationArgument message includes missing key, provided keys and full string" do
    exception = I18n::MissingInterpolationArgument.new('key', {:this => 'was given'}, 'string')
    assert_equal 'missing interpolation argument "key" in "string" ({:this=>"was given"} given)', exception.message
  end
end
