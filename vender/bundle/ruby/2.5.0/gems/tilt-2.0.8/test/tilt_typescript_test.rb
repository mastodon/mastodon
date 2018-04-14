require 'test_helper'
require 'tilt'

begin
  require 'tilt/typescript'

  class TypeScriptTemplateTest < Minitest::Test
    def setup
      @ts = "var x:number = 5"
      @js = /var x = 5;\s*/
    end

    test "is registered for '.ts' files" do
      assert_equal Tilt::TypeScriptTemplate, Tilt['test.ts']
    end

    test "is registered for '.tsx' files" do
      assert_equal Tilt::TypeScriptTemplate, Tilt['test.tsx']
    end

    test "compiles and evaluates the template on #render" do
      template = Tilt::TypeScriptTemplate.new { @ts }
      assert_match @js, template.render
    end

    test "supports source map" do
      template = Tilt::TypeScriptTemplate.new(inlineSourceMap: true)  { @ts }
      assert_match %r(sourceMappingURL), template.render
    end

    test "can be rendered more than once" do
      template = Tilt::TypeScriptTemplate.new { @ts }
      3.times { assert_match @js, template.render }
    end
  end
rescue LoadError
  warn "Tilt::TypeScriptTemplate (disabled)"
end
