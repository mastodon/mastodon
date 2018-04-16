require 'test_helper'

# thanks to Masao's String extensions, some tests taken from Masao's tests
# http://github.com/mutoh/gettext/blob/edbbe1fa8238fa12c7f26f2418403015f0270e47/test/test_string.rb

class I18nInterpolateTest < I18n::TestCase
  test "String interpolates a hash argument w/ named placeholders" do
    assert_equal "Masao Mutoh", I18n.interpolate("%{first} %{last}", :first => 'Masao', :last => 'Mutoh' )
  end

  test "String interpolates a hash argument w/ named placeholders (reverse order)" do
    assert_equal "Mutoh, Masao", I18n.interpolate("%{last}, %{first}", :first => 'Masao', :last => 'Mutoh' )
  end

  test "String interpolates named placeholders with sprintf syntax" do
    assert_equal "10, 43.4", I18n.interpolate("%<integer>d, %<float>.1f", :integer => 10, :float => 43.4)
  end

  test "String interpolates named placeholders with sprintf syntax, does not recurse" do
    assert_equal "%<not_translated>s", I18n.interpolate("%{msg}", :msg => '%<not_translated>s', :not_translated => 'should not happen' )
  end

  test "String interpolation does not replace anything when no placeholders are given" do
    assert_equal "aaa", I18n.interpolate("aaa", :num => 1)
  end

  test "String interpolation sprintf behaviour equals Ruby 1.9 behaviour" do
    assert_equal "1", I18n.interpolate("%<num>d", :num => 1)
    assert_equal "0b1", I18n.interpolate("%<num>#b", :num => 1)
    assert_equal "foo", I18n.interpolate("%<msg>s", :msg => "foo")
    assert_equal "1.000000", I18n.interpolate("%<num>f", :num => 1.0)
    assert_equal "  1", I18n.interpolate("%<num>3.0f", :num => 1.0)
    assert_equal "100.00", I18n.interpolate("%<num>2.2f", :num => 100.0)
    assert_equal "0x64", I18n.interpolate("%<num>#x", :num => 100.0)
    assert_raise(ArgumentError) { I18n.interpolate("%<num>,d", :num => 100) }
    assert_raise(ArgumentError) { I18n.interpolate("%<num>/d", :num => 100) }
  end

  test "String interpolation raises an I18n::MissingInterpolationArgument when the string has extra placeholders" do
    assert_raise(I18n::MissingInterpolationArgument) do # Ruby 1.9 msg: "key not found"
      I18n.interpolate("%{first} %{last}", :first => 'Masao')
    end
  end

  test "String interpolation does not raise when extra values were passed" do
    assert_nothing_raised do
      assert_equal "Masao Mutoh", I18n.interpolate("%{first} %{last}", :first => 'Masao', :last => 'Mutoh', :salutation => 'Mr.' )
    end
  end

  test "% acts as escape character in String interpolation" do
    assert_equal "%{first}", I18n.interpolate("%%{first}", :first => 'Masao')
    assert_equal "% 1", I18n.interpolate("%% %<num>d", :num => 1.0)
    assert_equal "%{num} %<num>d", I18n.interpolate("%%{num} %%<num>d", :num => 1)
  end

  def test_sprintf_mix_unformatted_and_formatted_named_placeholders
    assert_equal "foo 1.000000", I18n.interpolate("%{name} %<num>f", :name => "foo", :num => 1.0)
  end

  class RailsSafeBuffer < String

    def gsub(*args, &block)
      to_str.gsub(*args, &block)
    end

  end
  test "with String subclass that redefined gsub method" do
    assert_equal "Hello mars world", I18n.interpolate(RailsSafeBuffer.new("Hello %{planet} world"), :planet => 'mars') 
  end
end

class I18nMissingInterpolationCustomHandlerTest < I18n::TestCase
  def setup
    super
    @old_handler = I18n.config.missing_interpolation_argument_handler
    I18n.config.missing_interpolation_argument_handler = lambda do |key, values, string|
      "missing key is #{key}, values are #{values.inspect}, given string is '#{string}'"
    end
  end

  def teardown
    I18n.config.missing_interpolation_argument_handler = @old_handler
    super
  end

  test "String interpolation can use custom missing interpolation handler" do
    assert_equal %|Masao missing key is last, values are {:first=>"Masao"}, given string is '%{first} %{last}'|,
      I18n.interpolate("%{first} %{last}", :first => 'Masao')
  end
end
