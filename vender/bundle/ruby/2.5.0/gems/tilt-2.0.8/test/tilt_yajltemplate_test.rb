require 'test_helper'
require 'tilt'

begin
  require 'tilt/yajl'

  class YajlTemplateTest < Minitest::Test
    test "is registered for '.yajl' files" do
      assert_equal Tilt::YajlTemplate, Tilt['test.yajl']
    end

    test "compiles and evaluates the template on #render" do
      template = Tilt::YajlTemplate.new { "json = { :integer => 3, :string => 'hello' }" }
      output = template.render
      result = Yajl::Parser.parse(output)
      expect = {"integer" => 3,"string" => "hello"}
      assert_equal expect, result
    end

    test "can be rendered more than once" do
      template = Tilt::YajlTemplate.new { "json = { :integer => 3, :string => 'hello' }" }
      expect = {"integer" => 3,"string" => "hello"}
      3.times do
        output = template.render
        result = Yajl::Parser.parse(output)
        assert_equal expect, result
      end
    end

    test "evaluating ruby code" do
      template = Tilt::YajlTemplate.new { "json = { :integer => (3 * 2) }" }
      assert_equal '{"integer":6}', template.render
    end

    test "evaluating in an object scope" do
      template = Tilt::YajlTemplate.new { "json = { :string => 'Hey ' + @name + '!' }" }
      scope = Object.new
      scope.instance_variable_set :@name, 'Joe'
      assert_equal '{"string":"Hey Joe!"}', template.render(scope)
    end

    test "passing locals" do
      template = Tilt::YajlTemplate.new { "json = { :string => 'Hey ' + name + '!' }" }
      assert_equal '{"string":"Hey Joe!"}', template.render(Object.new, :name => 'Joe')
    end

    test "passing a block for yield" do
      template = Tilt::YajlTemplate.new { "json = { :string => 'Hey ' + yield + '!' }" }
      assert_equal '{"string":"Hey Joe!"}', template.render { 'Joe' }
      assert_equal '{"string":"Hey Moe!"}', template.render { 'Moe' }
    end

    test "template multiline" do
      template = Tilt::YajlTemplate.new { %Q{
        json = {
          :string   => "hello"
        }
      } }
      assert_equal '{"string":"hello"}', template.render
    end

    test "template can reuse existing json buffer" do
      template = Tilt::YajlTemplate.new { "json.merge! :string => 'hello'" }
      assert_equal '{"string":"hello"}', template.render
    end

    test "template can end with any statement" do
      template = Tilt::YajlTemplate.new { %Q{
        json = {
          :string   => "hello"
        }
        four = 2 * 2
        json[:integer] = four
        nil
      } }
      result = template.render
      assert( (result == '{"string":"hello","integer":4}') || (result == '{"integer":4,"string":"hello"}') )
    end

    test "option callback" do
      options = { :callback => 'foo' }
      template = Tilt::YajlTemplate.new(nil, options) { "json = { :string => 'hello' }" }
      assert_equal 'foo({"string":"hello"});', template.render
    end

    test "option variable" do
      options = { :variable => 'output' }
      template = Tilt::YajlTemplate.new(nil, options) { "json = { :string => 'hello' }" }
      assert_equal 'var output = {"string":"hello"};', template.render
    end

    test "option callback and variable" do
      options = { :callback => 'foo', :variable => 'output' }
      template = Tilt::YajlTemplate.new(nil, options) { "json = { :string => 'hello' }" }
      assert_equal 'var output = {"string":"hello"}; foo(output);', template.render
    end

  end
rescue LoadError
  warn "Tilt::YajlTemplateTest (disabled)"
end
