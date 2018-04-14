require 'test_helper'
require 'tilt'
require 'thread'

class CompileSiteTest < Minitest::Test
  def setup
    GC.start
  end

  class CompilingTemplate < Tilt::Template
    def prepare
    end

    def precompiled_template(locals)
      @data.inspect
    end
  end

  class Scope
  end

  test "compiling template source to a method" do
    template = CompilingTemplate.new { |t| "Hello World!" }
    template.render(Scope.new)
    method = template.send(:compiled_method, [])
    assert_kind_of UnboundMethod, method
  end

  # This test attempts to surface issues with compiling templates from
  # multiple threads.
  test "using compiled templates from multiple threads" do
    template = CompilingTemplate.new { 'template' }
    main_thread = Thread.current
    10.times do |i|
      threads =
        (1..50).map do |j|
          Thread.new {
            begin
              locals = { "local#{i}" => 'value' }
              res = template.render(self, locals)
              thread_id = Thread.current.object_id
              res = template.render(self, "local#{thread_id.abs.to_s}" => 'value')
            rescue => boom
              main_thread.raise(boom)
            end
          }
        end
      threads.each { |t| t.join }
    end
  end
end
