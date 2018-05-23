require 'test_helper'
require 'tilt'

begin
  class ::MockError < NameError
  end

  require 'tilt/haml'

  class HamlTemplateTest < Minitest::Test
    test "registered for '.haml' files" do
      assert_equal Tilt::HamlTemplate, Tilt['test.haml']
    end

    test "preparing and evaluating templates on #render" do
      template = Tilt::HamlTemplate.new { |t| "%p Hello World!" }
      assert_equal "<p>Hello World!</p>\n", template.render
    end

    test "can be rendered more than once" do
      template = Tilt::HamlTemplate.new { |t| "%p Hello World!" }
      3.times { assert_equal "<p>Hello World!</p>\n", template.render }
    end

    test "passing locals" do
      template = Tilt::HamlTemplate.new { "%p= 'Hey ' + name + '!'" }
      assert_equal "<p>Hey Joe!</p>\n", template.render(Object.new, :name => 'Joe')
    end

    test 'evaluating in default/nil scope' do
      template = Tilt::HamlTemplate.new { |t| '%p Hey unknown!' }
      assert_equal "<p>Hey unknown!</p>\n", template.render
      assert_equal "<p>Hey unknown!</p>\n", template.render(nil)
    end

    test 'evaluating in invalid, frozen scope' do
      template = Tilt::HamlTemplate.new { |t| '%p Hey unknown!' }
      assert_raises(ArgumentError) { template.render(Object.new.freeze) }
    end

    test "evaluating in an object scope" do
      template = Tilt::HamlTemplate.new { "%p= 'Hey ' + @name + '!'" }
      scope = Object.new
      scope.instance_variable_set :@name, 'Joe'
      assert_equal "<p>Hey Joe!</p>\n", template.render(scope)
    end

    test "passing a block for yield" do
      template = Tilt::HamlTemplate.new { "%p= 'Hey ' + yield + '!'" }
      assert_equal "<p>Hey Joe!</p>\n", template.render { 'Joe' }
    end

    test "backtrace file and line reporting without locals" do
      data = File.read(__FILE__).split("\n__END__\n").last
      fail unless data[0] == ?%
      template = Tilt::HamlTemplate.new('test.haml', 10) { data }
      begin
        template.render
        fail 'should have raised an exception'
      rescue => boom
        assert_kind_of NameError, boom
        line = boom.backtrace.grep(/^test\.haml:/).first
        assert line, "Backtrace didn't contain test.haml"
        _file, line, _meth = line.split(":")
        assert_equal '12', line
      end
    end

    test "backtrace file and line reporting with locals" do
      data = File.read(__FILE__).split("\n__END__\n").last
      fail unless data[0] == ?%
      template = Tilt::HamlTemplate.new('test.haml') { data }
      begin
        template.render(Object.new, :name => 'Joe', :foo => 'bar')
      rescue => boom
        assert_kind_of MockError, boom
        line = boom.backtrace.first
        file, line, _meth = line.split(":")
        assert_equal 'test.haml', file
        assert_equal '5', line
      end
    end
  end

  class CompiledHamlTemplateTest < Minitest::Test
    class Scope
    end

    test "compiling template source to a method" do
      template = Tilt::HamlTemplate.new { |t| "Hello World!" }
      template.render(Scope.new)
      method = template.send(:compiled_method, [])
      assert_kind_of UnboundMethod, method
    end

    test "passing locals" do
      template = Tilt::HamlTemplate.new { "%p= 'Hey ' + name + '!'" }
      assert_equal "<p>Hey Joe!</p>\n", template.render(Scope.new, :name => 'Joe')
    end

    test 'evaluating in default/nil scope' do
      template = Tilt::HamlTemplate.new { |t| '%p Hey unknown!' }
      assert_equal "<p>Hey unknown!</p>\n", template.render
      assert_equal "<p>Hey unknown!</p>\n", template.render(nil)
    end

    test 'evaluating in invalid, frozen scope' do
      template = Tilt::HamlTemplate.new { |t| '%p Hey unknown!' }
      assert_raises(ArgumentError) { template.render(Object.new.freeze) }
    end

    test "evaluating in an object scope" do
      template = Tilt::HamlTemplate.new { "%p= 'Hey ' + @name + '!'" }
      scope = Scope.new
      scope.instance_variable_set :@name, 'Joe'
      assert_equal "<p>Hey Joe!</p>\n", template.render(scope)
    end

    test "passing a block for yield" do
      template = Tilt::HamlTemplate.new { "%p= 'Hey ' + yield + '!'" }
      assert_equal "<p>Hey Joe!</p>\n", template.render(Scope.new) { 'Joe' }
    end

    test "backtrace file and line reporting without locals" do
      data = File.read(__FILE__).split("\n__END__\n").last
      fail unless data[0] == ?%
      template = Tilt::HamlTemplate.new('test.haml', 10) { data }
      begin
        template.render(Scope.new)
        fail 'should have raised an exception'
      rescue => boom
        assert_kind_of NameError, boom
        line = boom.backtrace.grep(/^test\.haml:/).first
        assert line, "Backtrace didn't contain test.haml"
        _file, line, _meth = line.split(":")
        assert_equal '12', line
      end
    end

    test "backtrace file and line reporting with locals" do
      data = File.read(__FILE__).split("\n__END__\n").last
      fail unless data[0] == ?%
      template = Tilt::HamlTemplate.new('test.haml') { data }
      begin
        template.render(Scope.new, :name => 'Joe', :foo => 'bar')
      rescue => boom
        assert_kind_of MockError, boom
        line = boom.backtrace.first
        file, line, _meth = line.split(":")
        assert_equal 'test.haml', file
        assert_equal '5', line
      end
    end
  end
rescue LoadError
  warn "Tilt::HamlTemplate (disabled)"
end

__END__
%html
  %body
    %h1= "Hey #{name}"

    = raise MockError

    %p we never get here
