require 'test_helper'
require 'tilt'

begin
  require 'pathname'
  require 'tilt/less'

  class LessTemplateTest < Minitest::Test
    def assert_similar(a, b)
      assert_equal a.gsub(/\s+/m, ' '), b.gsub(/\s+/m, ' ')
    end

    test "is registered for '.less' files" do
      assert_equal Tilt::LessTemplate, Tilt['test.less']
    end

    test "compiles and evaluates the template on #render" do
      template = Tilt::LessTemplate.new { |t| ".bg { background-color: #0000ff; } \n#main\n { .bg; }\n" }
      assert_similar ".bg {\n  background-color: #0000ff;\n}\n#main {\n  background-color: #0000ff;\n}\n", template.render
    end

    test "can be rendered more than once" do
      template = Tilt::LessTemplate.new { |t| ".bg { background-color: #0000ff; } \n#main\n { .bg; }\n" }
      3.times { assert_similar ".bg {\n  background-color: #0000ff;\n}\n#main {\n  background-color: #0000ff;\n}\n", template.render }
    end

    test "can be passed a load path" do
      template = Tilt::LessTemplate.new({
        :paths => [Pathname(__FILE__).dirname]
      }) {
        <<-EOLESS
        @import 'tilt_lesstemplate_test.less';
        .bg {background-color: @text-color;}
        EOLESS
      }
      assert_similar ".bg {\n  background-color: #ffc0cb;\n}\n", template.render
    end
  end

rescue LoadError
  warn "Tilt::LessTemplate (disabled)"
end
