require 'test_helper'

class InterpolationCompilerTest < I18n::TestCase
  Compiler = I18n::Backend::InterpolationCompiler::Compiler

  def compile_and_interpolate(str, values = {})
    Compiler.compile_if_an_interpolation(str).i18n_interpolate(values)
  end

  def assert_escapes_interpolation_key(expected, malicious_str)
    assert_equal(expected, Compiler.send(:escape_key_sym, malicious_str))
  end

  def test_escape_key_properly_escapes
    assert_escapes_interpolation_key ':"\""',       '"'
    assert_escapes_interpolation_key ':"\\\\"',     '\\'
    assert_escapes_interpolation_key ':"\\\\\""',   '\\"'
    assert_escapes_interpolation_key ':"\#{}"',     '#{}'
    assert_escapes_interpolation_key ':"\\\\\#{}"', '\#{}'
  end

  def assert_escapes_plain_string(expected, plain_str)
    assert_equal expected, Compiler.send(:escape_plain_str, plain_str)
  end

  def test_escape_plain_string_properly_escapes
    assert_escapes_plain_string '\\"',    '"'
    assert_escapes_plain_string '\'',     '\''
    assert_escapes_plain_string '\\#',    '#'
    assert_escapes_plain_string '\\#{}',  '#{}'
    assert_escapes_plain_string '\\\\\\"','\\"'
  end

  def test_non_interpolated_strings_or_arrays_dont_get_compiled
    ['abc', '\\{a}}', '{a}}', []].each do |obj|
      Compiler.compile_if_an_interpolation(obj)
      assert_equal false, obj.respond_to?(:i18n_interpolate)
    end
  end

  def test_interpolated_string_gets_compiled
    assert_equal '-A-', compile_and_interpolate('-%{a}-', :a => 'A')
  end

  def assert_handles_key(str, key)
    assert_equal 'A', compile_and_interpolate(str, key => 'A')
  end

  def test_compiles_fancy_keys
    assert_handles_key('%{\}',       :'\\'    )
    assert_handles_key('%{#}',       :'#'     )
    assert_handles_key('%{#{}',      :'#{'    )
    assert_handles_key('%{#$SAFE}',  :'#$SAFE')
    assert_handles_key('%{\000}',    :'\000'  )
    assert_handles_key('%{\'}',      :'\''    )
    assert_handles_key('%{\'\'}',    :'\'\''  )
    assert_handles_key('%{a.b}',     :'a.b'   )
    assert_handles_key('%{ }',       :' '     )
    assert_handles_key('%{:}',       :':'     )
    assert_handles_key("%{:''}",     :":''"   )
    assert_handles_key('%{:"}',      :':"'    )
  end

  def test_str_containing_only_escaped_interpolation_is_handled_correctly
    assert_equal 'abc %{x}', compile_and_interpolate('abc %%{x}')
  end

  def test_handles_weird_strings
    assert_equal '#{} a',         compile_and_interpolate('#{} %{a}',         :a    => 'a')
    assert_equal '"#{abc}"',      compile_and_interpolate('"#{ab%{a}c}"',     :a    => '' )
    assert_equal 'a}',            compile_and_interpolate('%{{a}}',           :'{a' => 'a')
    assert_equal '"',             compile_and_interpolate('"%{a}',            :a    => '' )
    assert_equal 'a%{a}',         compile_and_interpolate('%{a}%%{a}',        :a    => 'a')
    assert_equal '%%{a}',         compile_and_interpolate('%%%{a}')
    assert_equal '\";eval("a")',  compile_and_interpolate('\";eval("%{a}")',  :a    => 'a')
    assert_equal '\";eval("a")',  compile_and_interpolate('\";eval("a")%{a}', :a    => '' )
    assert_equal "\na",           compile_and_interpolate("\n%{a}",           :a    => 'a')
  end

  def test_raises_exception_when_argument_is_missing
    assert_raise(I18n::MissingInterpolationArgument) do
      compile_and_interpolate('%{first} %{last}', :first => 'first')
    end
  end

  def test_custom_missing_interpolation_argument_handler
    old_handler = I18n.config.missing_interpolation_argument_handler
    I18n.config.missing_interpolation_argument_handler = lambda do |key, values, string|
      "missing key is #{key}, values are #{values.inspect}, given string is '#{string}'"
    end
    assert_equal %|first missing key is last, values are {:first=>"first"}, given string is '%{first} %{last}'|,
        compile_and_interpolate('%{first} %{last}', :first => 'first')
  ensure
    I18n.config.missing_interpolation_argument_handler = old_handler
  end
end

class I18nBackendInterpolationCompilerTest < I18n::TestCase
  class Backend < I18n::Backend::Simple
    include I18n::Backend::InterpolationCompiler
  end

  include I18n::Tests::Interpolation

  def setup
    I18n.backend = Backend.new
    super
  end

  # pre-compile default strings to make sure we are testing I18n::Backend::InterpolationCompiler
  def interpolate(*args)
    options = args.last.kind_of?(Hash) ? args.last : {}
    if default_str = options[:default]
      I18n::Backend::InterpolationCompiler::Compiler.compile_if_an_interpolation(default_str)
    end
    super
  end
end
