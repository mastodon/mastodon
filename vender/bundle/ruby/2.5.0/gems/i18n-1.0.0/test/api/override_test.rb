require 'test_helper'

class I18nOverrideTest < I18n::TestCase
  module OverrideInverse
    def translate(*args)
      super(*args).reverse
    end
    alias :t :translate
  end

  module OverrideSignature
    def translate(*args)
      args.first + args[1]
    end
    alias :t :translate
  end

  def setup
    super
    @I18n = I18n.dup
    @I18n.backend = I18n::Backend::Simple.new
  end

  test "make sure modules can overwrite I18n methods" do
    @I18n.extend OverrideInverse
    @I18n.backend.store_translations('en', :foo => 'bar')

    assert_equal 'rab', @I18n.translate(:foo, :locale => 'en')
    assert_equal 'rab', @I18n.t(:foo, :locale => 'en')
    assert_equal 'rab', @I18n.translate!(:foo, :locale => 'en')
    assert_equal 'rab', @I18n.t!(:foo, :locale => 'en')
  end

  test "make sure modules can overwrite I18n signature" do
    exception = catch(:exception) do
      @I18n.t('Hello', 'Welcome message on home page', :tokenize => true, :throw => true)
    end
    assert exception.message
    @I18n.extend OverrideSignature
    assert_equal 'HelloWelcome message on home page', @I18n.translate('Hello', 'Welcome message on home page', :tokenize => true) # tr8n example
  end
end
