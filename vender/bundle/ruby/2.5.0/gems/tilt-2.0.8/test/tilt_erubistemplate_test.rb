require 'test_helper'
require 'tilt'

begin
  require 'tilt/erubis'
  class ErubisTemplateTest < Minitest::Test
    test "registered for '.erubis' files" do
      assert_equal Tilt::ErubisTemplate, Tilt['test.erubis']
      assert_equal Tilt::ErubisTemplate, Tilt['test.html.erubis']
    end

    test "registered above ERB" do
      %w[erb rhtml].each do |ext|
        lazy = Tilt.lazy_map[ext]
        erubis_idx = lazy.index { |klass, file| klass == 'Tilt::ErubisTemplate' }
        erb_idx = lazy.index { |klass, file| klass == 'Tilt::ERBTemplate' }
        assert erubis_idx < erb_idx,
          "#{erubis_idx} should be lower than #{erb_idx}"
      end
    end

    test "preparing and evaluating templates on #render" do
      template = Tilt::ErubisTemplate.new { |t| "Hello World!" }
      assert_equal "Hello World!", template.render
    end

    test "can be rendered more than once" do
      template = Tilt::ErubisTemplate.new { |t| "Hello World!" }
      3.times { assert_equal "Hello World!", template.render }
    end

    test "passing locals" do
      template = Tilt::ErubisTemplate.new { 'Hey <%= name %>!' }
      assert_equal "Hey Joe!", template.render(Object.new, :name => 'Joe')
    end

    test "evaluating in an object scope" do
      template = Tilt::ErubisTemplate.new { 'Hey <%= @name %>!' }
      scope = Object.new
      scope.instance_variable_set :@name, 'Joe'
      assert_equal "Hey Joe!", template.render(scope)
    end

    class MockOutputVariableScope
      attr_accessor :exposed_buffer
    end

    test "exposing the buffer to the template by default" do
      begin
        Tilt::ErubisTemplate.default_output_variable = '@_out_buf'
        template = Tilt::ErubisTemplate.new { '<% self.exposed_buffer = @_out_buf %>hey' }
        scope = MockOutputVariableScope.new
        template.render(scope)
        refute_nil scope.exposed_buffer
        assert_equal scope.exposed_buffer, 'hey'
      ensure
        Tilt::ErubisTemplate.default_output_variable = '_erbout'
      end
    end

    test "passing a block for yield" do
      template = Tilt::ErubisTemplate.new { 'Hey <%= yield %>!' }
      assert_equal "Hey Joe!", template.render { 'Joe' }
    end

    test "backtrace file and line reporting without locals" do
      data = File.read(__FILE__).split("\n__END__\n").last
      fail unless data[0] == ?<
      template = Tilt::ErubisTemplate.new('test.erubis', 11) { data }
      begin
        template.render
        fail 'should have raised an exception'
      rescue => boom
        assert_kind_of NameError, boom
        line = boom.backtrace.grep(/^test\.erubis:/).first
        assert line, "Backtrace didn't contain test.erubis"
        _file, line, _meth = line.split(":")
        assert_equal '13', line
      end
    end

    test "backtrace file and line reporting with locals" do
      data = File.read(__FILE__).split("\n__END__\n").last
      fail unless data[0] == ?<
      template = Tilt::ErubisTemplate.new('test.erubis', 1) { data }
      begin
        template.render(nil, :name => 'Joe', :foo => 'bar')
        fail 'should have raised an exception'
      rescue => boom
        assert_kind_of RuntimeError, boom
        line = boom.backtrace.first
        file, line, _meth = line.split(":")
        assert_equal 'test.erubis', file
        assert_equal '6', line
      end
    end

    test "erubis template options" do
      template = Tilt::ErubisTemplate.new(nil, :pattern => '\{% %\}') { 'Hey {%= @name %}!' }
      scope = Object.new
      scope.instance_variable_set :@name, 'Joe'
      assert_equal "Hey Joe!", template.render(scope)
    end

    test "using an instance variable as the outvar" do
      template = Tilt::ErubisTemplate.new(nil, :outvar => '@buf') { "<%= 1 + 1 %>" }
      scope = Object.new
      scope.instance_variable_set(:@buf, 'original value')
      assert_equal '2', template.render(scope)
      assert_equal 'original value', scope.instance_variable_get(:@buf)
    end

    test "using Erubis::EscapedEruby subclass via :engine_class option" do
      template = Tilt::ErubisTemplate.new(nil, :engine_class => ::Erubis::EscapedEruby) { |t| %(<%= "<p>Hello World!</p>" %>) }
      assert_equal "&lt;p&gt;Hello World!&lt;/p&gt;", template.render
    end

    test "using :escape_html => true option" do
      template = Tilt::ErubisTemplate.new(nil, :escape_html => true) { |t| %(<%= "<p>Hello World!</p>" %>) }
      assert_equal "&lt;p&gt;Hello World!&lt;/p&gt;", template.render
    end

    test "using :escape_html => false option" do
      template = Tilt::ErubisTemplate.new(nil, :escape_html => false) { |t| %(<%= "<p>Hello World!</p>" %>) }
      assert_equal "<p>Hello World!</p>", template.render
    end

    test "erubis default does not escape html" do
      template = Tilt::ErubisTemplate.new { |t| %(<%= "<p>Hello World!</p>" %>) }
      assert_equal "<p>Hello World!</p>", template.render
    end

    test "does not modify options argument" do
      options_hash = {:escape_html => true}
      Tilt::ErubisTemplate.new(nil, options_hash) { |t| "Hello World!" }
      assert_equal({:escape_html => true}, options_hash)
    end
  end
rescue LoadError
  warn "Tilt::ErubisTemplate (disabled)"
end

__END__
<html>
<body>
  <h1>Hey <%= name %>!</h1>


  <p><% fail %></p>
</body>
</html>
