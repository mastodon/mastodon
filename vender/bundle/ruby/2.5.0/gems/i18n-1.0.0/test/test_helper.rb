$KCODE = 'u' if RUBY_VERSION <= '1.9'

require 'minitest/autorun'
TEST_CASE = defined?(Minitest::Test) ? Minitest::Test : MiniTest::Unit::TestCase

# TODO: Remove these aliases and update tests accordingly.
class TEST_CASE
  alias :assert_raise :assert_raises
  alias :assert_not_equal :refute_equal

  def assert_nothing_raised(*args)
    yield
  end
end

require 'bundler/setup'
require 'i18n'
require 'mocha/setup'
require 'test_declarative'

class I18n::TestCase < TEST_CASE
  def self.key_value?
    defined?(ActiveSupport)
  end

  def setup
    super
    I18n.enforce_available_locales = false
  end

  def teardown
    I18n.locale = nil
    I18n.default_locale = nil
    I18n.load_path = nil
    I18n.available_locales = nil
    I18n.backend = nil
    I18n.default_separator = nil
    I18n.enforce_available_locales = true
    super
  end

  protected

  def translations
    I18n.backend.instance_variable_get(:@translations)
  end

  def store_translations(locale, data)
    I18n.backend.store_translations(locale, data)
  end

  def locales_dir
    File.dirname(__FILE__) + '/test_data/locales'
  end
end

class DummyRackApp
  def call(env)
    I18n.locale = :es
  end
end
