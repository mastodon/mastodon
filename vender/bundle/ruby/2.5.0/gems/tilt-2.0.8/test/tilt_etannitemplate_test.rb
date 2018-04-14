require 'test_helper'
require 'tilt'
require 'tilt/etanni'

class EtanniTemplateTest < Minitest::Test
  test "registered for '.etn' files" do
    assert_equal Tilt::EtanniTemplate, Tilt['test.etn']
  end

  test "registered for '.etanni' files" do
    assert_equal Tilt::EtanniTemplate, Tilt['test.etanni']
  end

  test "loading and evaluating templates on #render" do
    template = Tilt::EtanniTemplate.new { |t| "Hello World!" }
    assert_equal "Hello World!", template.render
  end

  test "can be rendered more than once" do
    template = Tilt::EtanniTemplate.new { |t| "Hello World!" }
    3.times { assert_equal "Hello World!", template.render }
  end

  test "passing locals" do
    template = Tilt::EtanniTemplate.new { 'Hey #{name}!' }
    assert_equal "Hey Joe!", template.render(Object.new, :name => 'Joe')
  end

  test "evaluating in an object scope" do
    template = Tilt::EtanniTemplate.new { 'Hey #{@name}!' }
    scope = Object.new
    scope.instance_variable_set :@name, 'Joe'
    assert_equal "Hey Joe!", template.render(scope)
  end

  test "passing a block for yield" do
    template = Tilt::EtanniTemplate.new { 'Hey #{yield}!' }
    assert_equal "Hey Joe!", template.render { 'Joe' }
    assert_equal "Hey Moe!", template.render { 'Moe' }
  end

  test "multiline templates" do
    template = Tilt::EtanniTemplate.new { "Hello\nWorld!\n" }
    assert_equal "Hello\nWorld!", template.render
  end

  test "backtrace file and line reporting without locals" do
    data = File.read(__FILE__).split("\n__END__\n").last
    fail unless data[0] == ?<
    template = Tilt::EtanniTemplate.new('test.etn', 11) { data }
    begin
      template.render
      fail 'should have raised an exception'
    rescue => boom
      assert_kind_of NameError, boom
      line = boom.backtrace.grep(/^test\.etn:/).first
      assert line, "Backtrace didn't contain test.etn"
      _file, line, _meth = line.split(":")
      assert_equal '13', line
    end
  end

  test "backtrace file and line reporting with locals" do
    data = File.read(__FILE__).split("\n__END__\n").last
    fail unless data[0] == ?<
    template = Tilt::EtanniTemplate.new('test.etn', 1) { data }
    begin
      template.render(nil, :name => 'Joe', :foo => 'bar')
      fail 'should have raised an exception'
    rescue => boom
      assert_kind_of RuntimeError, boom
      line = boom.backtrace.first
      file, line, _meth = line.split(":")
      assert_equal 'test.etn', file
      assert_equal '6', line
    end
  end
end


class CompiledEtanniTemplateTest < Minitest::Test
  def teardown
    GC.start
  end

  class Scope
  end

  test "compiling template source to a method" do
    template = Tilt::EtanniTemplate.new { |t| "Hello World!" }
    template.render(Scope.new)
    method = template.send(:compiled_method, [])
    assert_kind_of UnboundMethod, method
  end

  test "loading and evaluating templates on #render" do
    template = Tilt::EtanniTemplate.new { |t| "Hello World!" }
    assert_equal "Hello World!", template.render(Scope.new)
  end

  test "passing locals" do
    template = Tilt::EtanniTemplate.new { 'Hey #{name}!' }
    assert_equal "Hey Joe!", template.render(Scope.new, :name => 'Joe')
    assert_equal "Hey Moe!", template.render(Scope.new, :name => 'Moe')
  end

  test "evaluating in an object scope" do
    template = Tilt::EtanniTemplate.new { 'Hey #{@name}!' }
    scope = Scope.new
    scope.instance_variable_set :@name, 'Joe'
    assert_equal "Hey Joe!", template.render(scope)
    scope.instance_variable_set :@name, 'Moe'
    assert_equal "Hey Moe!", template.render(scope)
  end

  test "passing a block for yield" do
    template = Tilt::EtanniTemplate.new { 'Hey #{yield}!' }
    assert_equal "Hey Joe!", template.render(Scope.new) { 'Joe' }
    assert_equal "Hey Moe!", template.render(Scope.new) { 'Moe' }
  end

  test "multiline templates" do
    template = Tilt::EtanniTemplate.new { "Hello\nWorld!\n" }
    assert_equal "Hello\nWorld!", template.render(Scope.new)
  end

  test "template with '}'" do
    template = Tilt::EtanniTemplate.new { "Hello }" }
    assert_equal "Hello }", template.render
  end

  test "backtrace file and line reporting without locals" do
    data = File.read(__FILE__).split("\n__END__\n").last
    fail unless data[0] == ?<
    template = Tilt::EtanniTemplate.new('test.etn', 11) { data }
    begin
      template.render(Scope.new)
      fail 'should have raised an exception'
    rescue => boom
      assert_kind_of NameError, boom
      line = boom.backtrace.first
      line = boom.backtrace.grep(/^test\.etn:/).first
      assert line, "Backtrace didn't contain test.etn"
      _file, line, _meth = line.split(":")
      assert_equal '13', line
    end
  end

  test "backtrace file and line reporting with locals" do
    data = File.read(__FILE__).split("\n__END__\n").last
    fail unless data[0] == ?<
    template = Tilt::EtanniTemplate.new('test.etn') { data }
    begin
      template.render(Scope.new, :name => 'Joe', :foo => 'bar')
      fail 'should have raised an exception'
    rescue => boom
      assert_kind_of RuntimeError, boom
      line = boom.backtrace.first
      file, line, _meth = line.split(":")
      assert_equal 'test.etn', file
      assert_equal '6', line
    end
  end
end

__END__
<html>
<body>
  <h1>Hey #{name}!</h1>


  <p>#{fail}</p>
</body>
</html>
