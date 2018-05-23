# coding: utf-8
require 'test_helper'
require 'tilt'
require 'tilt/erb'
require 'tempfile'

class ERBTemplateTest < Minitest::Test
  test "registered for '.erb' files" do
    assert_includes Tilt.lazy_map['erb'], ['Tilt::ERBTemplate', 'tilt/erb']
  end

  test "registered for '.rhtml' files" do
    assert_includes Tilt.lazy_map['rhtml'], ['Tilt::ERBTemplate', 'tilt/erb']
  end

  test "loading and evaluating templates on #render" do
    template = Tilt::ERBTemplate.new { |t| "Hello World!" }
    assert_equal "Hello World!", template.render
  end

  test "can be rendered more than once" do
    template = Tilt::ERBTemplate.new { |t| "Hello World!" }
    3.times { assert_equal "Hello World!", template.render }
  end

  test "passing locals" do
    template = Tilt::ERBTemplate.new { 'Hey <%= name %>!' }
    assert_equal "Hey Joe!", template.render(Object.new, :name => 'Joe')
  end

  test "evaluating in an object scope" do
    template = Tilt::ERBTemplate.new { 'Hey <%= @name %>!' }
    scope = Object.new
    scope.instance_variable_set :@name, 'Joe'
    assert_equal "Hey Joe!", template.render(scope)
  end

  class MockOutputVariableScope
    attr_accessor :exposed_buffer
  end

  test "exposing the buffer to the template by default" do
    begin
      Tilt::ERBTemplate.default_output_variable = '@_out_buf'
      template = Tilt::ERBTemplate.new { '<% self.exposed_buffer = @_out_buf %>hey' }
      scope = MockOutputVariableScope.new
      template.render(scope)
      refute_nil scope.exposed_buffer
      assert_equal scope.exposed_buffer, 'hey'
    ensure
      Tilt::ERBTemplate.default_output_variable = '_erbout'
    end
  end

  test "passing a block for yield" do
    template = Tilt::ERBTemplate.new { 'Hey <%= yield %>!' }
    assert_equal "Hey Joe!", template.render { 'Joe' }
  end

  test "backtrace file and line reporting without locals" do
    data = File.read(__FILE__).split("\n__END__\n").last
    fail unless data[0] == ?<
    template = Tilt::ERBTemplate.new('test.erb', 11) { data }
    begin
      template.render
      fail 'should have raised an exception'
    rescue => boom
      assert_kind_of NameError, boom
      line = boom.backtrace.grep(/^test\.erb:/).first
      assert line, "Backtrace didn't contain test.erb"
      _file, line, _meth = line.split(":")
      assert_equal '13', line
    end
  end

  test "backtrace file and line reporting with locals" do
    data = File.read(__FILE__).split("\n__END__\n").last
    fail unless data[0] == ?<
    template = Tilt::ERBTemplate.new('test.erb', 1) { data }
    begin
      template.render(nil, :name => 'Joe', :foo => 'bar')
      fail 'should have raised an exception'
    rescue => boom
      assert_kind_of RuntimeError, boom
      line = boom.backtrace.first
      file, line, _meth = line.split(":")
      assert_equal 'test.erb', file
      assert_equal '6', line
    end
  end

  test "explicit disabling of trim mode" do
    template = Tilt::ERBTemplate.new('test.erb', 1, :trim => false) { "\n<%= 1 + 1 %>\n" }
    assert_equal "\n2\n", template.render
  end

  test "default stripping trim mode" do
    template = Tilt::ERBTemplate.new('test.erb', 1) { "\n<%= 1 + 1 %>\n" }
    assert_equal "\n2", template.render
  end

  test "stripping trim mode" do
    template = Tilt::ERBTemplate.new('test.erb', 1, :trim => '-') { "\n<%= 1 + 1 -%>\n" }
    assert_equal "\n2", template.render
  end

  test "shorthand whole line syntax trim mode" do
    template = Tilt::ERBTemplate.new('test.erb', :trim => '%') { "\n% if true\nhello\n%end\n" }
    assert_equal "\nhello\n", template.render
  end

  test "using an instance variable as the outvar" do
    template = Tilt::ERBTemplate.new(nil, :outvar => '@buf') { "<%= 1 + 1 %>" }
    scope = Object.new
    scope.instance_variable_set(:@buf, 'original value')
    assert_equal '2', template.render(scope)
    assert_equal 'original value', scope.instance_variable_get(:@buf)
  end
end

class CompiledERBTemplateTest < Minitest::Test
  def teardown
    GC.start
  end

  class Scope
  end

  test "compiling template source to a method" do
    template = Tilt::ERBTemplate.new { |t| "Hello World!" }
    template.render(Scope.new)
    method = template.send(:compiled_method, [])
    assert_kind_of UnboundMethod, method
  end

  test "loading and evaluating templates on #render" do
    template = Tilt::ERBTemplate.new { |t| "Hello World!" }
    assert_equal "Hello World!", template.render(Scope.new)
    assert_equal "Hello World!", template.render(Scope.new)
  end

  test "passing locals" do
    template = Tilt::ERBTemplate.new { 'Hey <%= name %>!' }
    assert_equal "Hey Joe!", template.render(Scope.new, :name => 'Joe')
  end

  test "evaluating in an object scope" do
    template = Tilt::ERBTemplate.new { 'Hey <%= @name %>!' }
    scope = Scope.new
    scope.instance_variable_set :@name, 'Joe'
    assert_equal "Hey Joe!", template.render(scope)
    scope.instance_variable_set :@name, 'Jane'
    assert_equal "Hey Jane!", template.render(scope)
  end

  test "passing a block for yield" do
    template = Tilt::ERBTemplate.new { 'Hey <%= yield %>!' }
    assert_equal "Hey Joe!", template.render(Scope.new) { 'Joe' }
    assert_equal "Hey Jane!", template.render(Scope.new) { 'Jane' }
  end

  test "backtrace file and line reporting without locals" do
    data = File.read(__FILE__).split("\n__END__\n").last
    fail unless data[0] == ?<
    template = Tilt::ERBTemplate.new('test.erb', 11) { data }
    begin
      template.render(Scope.new)
      fail 'should have raised an exception'
    rescue => boom
      assert_kind_of NameError, boom
      line = boom.backtrace.grep(/^test\.erb:/).first
      assert line, "Backtrace didn't contain test.erb"
      _file, line, _meth = line.split(":")
      assert_equal '13', line
    end
  end

  test "backtrace file and line reporting with locals" do
    data = File.read(__FILE__).split("\n__END__\n").last
    fail unless data[0] == ?<
    template = Tilt::ERBTemplate.new('test.erb') { data }
    begin
      template.render(Scope.new, :name => 'Joe', :foo => 'bar')
      fail 'should have raised an exception'
    rescue => boom
      assert_kind_of RuntimeError, boom
      line = boom.backtrace.first
      file, line, _meth = line.split(":")
      assert_equal 'test.erb', file
      assert_equal '6', line
    end
  end

  test "default stripping trim mode" do
    template = Tilt::ERBTemplate.new('test.erb') { "\n<%= 1 + 1 %>\n" }
    assert_equal "\n2", template.render(Scope.new)
  end

  test "stripping trim mode" do
    template = Tilt::ERBTemplate.new('test.erb', :trim => '-') { "\n<%= 1 + 1 -%>\n" }
    assert_equal "\n2", template.render(Scope.new)
  end

  test "shorthand whole line syntax trim mode" do
    template = Tilt::ERBTemplate.new('test.erb', :trim => '%') { "\n% if true\nhello\n%end\n" }
    assert_equal "\nhello\n", template.render(Scope.new)
  end

  test "encoding with magic comment" do
    f = Tempfile.open("template")
    f.puts('<%# coding: UTF-8 %>')
    f.puts('ふが <%= @hoge %>')
    f.close()
    @hoge = "ほげ"
    erb = Tilt::ERBTemplate.new(f.path)
    3.times { erb.render(self) }
    f.delete
  end

  test "encoding with :default_encoding" do
    f = Tempfile.open("template")
    f.puts('ふが <%= @hoge %>')
    f.close()
    @hoge = "ほげ"
    erb = Tilt::ERBTemplate.new(f.path, :default_encoding => 'UTF-8')
    3.times { erb.render(self) }
    f.delete
  end
end

__END__
<html>
<body>
  <h1>Hey <%= name %>!</h1>


  <p><% fail %></p>
</body>
</html>
