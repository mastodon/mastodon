require 'test_helper'
require 'tilt'
require 'tilt/mapping'

module Tilt

  class MappingTest < Minitest::Test
    class Stub
    end

    class Stub2
    end

    setup do
      @mapping = Mapping.new
    end

    test "registered?" do
      @mapping.register(Stub, 'foo', 'bar')
      assert @mapping.registered?('foo')
      assert @mapping.registered?('bar')
      refute @mapping.registered?('baz')
    end

    test "lookups on registered" do
      @mapping.register(Stub, 'foo', 'bar')
      assert_equal Stub, @mapping['foo']
      assert_equal Stub, @mapping['bar']
      assert_equal Stub, @mapping['hello.foo']
      assert_nil @mapping['foo.baz']
    end

    test "can be dup'd" do
      @mapping.register(Stub, 'foo')
      other = @mapping.dup
      assert other.registered?('foo')

      # @mapping doesn't leak to other
      @mapping.register(Stub, 'bar')
      refute other.registered?('bar')

      # other doesn't leak to @mapping
      other.register(Stub, 'baz')
      refute @mapping.registered?('baz')
    end

    test "#extensions_for" do
      @mapping.register(Stub, 'foo', 'bar')
      assert_equal ['foo', 'bar'].sort, @mapping.extensions_for(Stub).sort
    end

    test "supports old-style #register" do
      @mapping.register('foo', Stub)
      assert_equal Stub, @mapping['foo']
    end

    context "lazy with one template class" do
      setup do
        @mapping.register_lazy('MyTemplate', 'my_template', 'mt')
        @loaded_before = $LOADED_FEATURES.dup
      end

      teardown do
        Object.send :remove_const, :MyTemplate if defined? ::MyTemplate
        $LOADED_FEATURES.replace(@loaded_before)
      end

      test "registered?" do
        assert @mapping.registered?('mt')
      end

      test "#extensions_for" do
        assert_equal ['mt'], @mapping.extensions_for('MyTemplate')
      end

      test "basic lookup" do
        req = proc do |file|
          assert_equal 'my_template', file
          class ::MyTemplate; end
          true
        end

        @mapping.stub :require, req do
          klass = @mapping['hello.mt']
          assert_equal ::MyTemplate, klass
        end
      end

      test "doesn't require when template class is present" do
        class ::MyTemplate; end

        req = proc do |file|
          flunk "#require shouldn't be called"
        end

        @mapping.stub :require, req do
          klass = @mapping['hello.mt']
          assert_equal ::MyTemplate, klass
        end
      end

      test "doesn't require when the template class is autoloaded, and then defined" do
        Object.autoload :MyTemplate, 'mytemplate'
        did_load = require 'mytemplate'
        assert did_load, "mytemplate wasn't freshly required"

        req = proc do |file|
          flunk "#require shouldn't be called"
        end

        @mapping.stub :require, req do
          klass = @mapping['hello.mt']
          assert_equal ::MyTemplate, klass
        end
      end

      test "raises NameError when the class name is defined" do
        req = proc do |file|
          # do nothing
        end

        @mapping.stub :require, req do
          assert_raises(NameError) do
            @mapping['hello.mt']
          end
        end
      end
    end

    context "lazy with two template classes" do
      setup do
        @mapping.register_lazy('MyTemplate1', 'my_template1', 'mt')
        @mapping.register_lazy('MyTemplate2', 'my_template2', 'mt')
      end

      teardown do
        Object.send :remove_const, :MyTemplate1 if defined? ::MyTemplate1
        Object.send :remove_const, :MyTemplate2 if defined? ::MyTemplate2
      end

      test "registered?" do
        assert @mapping.registered?('mt')
      end

      test "only attempt to load the last template" do
        req = proc do |file|
          assert_equal 'my_template2', file
          class ::MyTemplate2; end
          true
        end

        @mapping.stub :require, req do
          klass = @mapping['hello.mt']
          assert_equal ::MyTemplate2, klass
        end
      end

      test "uses the first template if it's present" do
        class ::MyTemplate1; end

        req = proc do |file|
          flunk
        end

        @mapping.stub :require, req do
          klass = @mapping['hello.mt']
          assert_equal ::MyTemplate1, klass
        end
      end

      test "falls back when LoadError is thrown" do
        req = proc do |file|
          raise LoadError unless file == 'my_template1'
          class ::MyTemplate1; end
          true
        end

        @mapping.stub :require, req do
          klass = @mapping['hello.mt']
          assert_equal ::MyTemplate1, klass
        end
      end

      test "raises the first LoadError when everything fails" do
        req = proc do |file|
          raise LoadError, file
        end

        @mapping.stub :require, req do
          err = assert_raises(LoadError) do
            @mapping['hello.mt']
          end

          assert_equal 'my_template2', err.message
        end
      end

      test "handles autoloaded constants" do
        Object.autoload :MyTemplate2, 'my_template2'
        class ::MyTemplate1; end

        assert_equal MyTemplate1, @mapping['hello.mt']
      end
    end

    test "raises NameError on invalid class name" do
      @mapping.register_lazy '#foo', 'my_template', 'mt'

      req = proc do |file|
        # do nothing
      end

      @mapping.stub :require, req do
        assert_raises(NameError) do
          @mapping['hello.mt']
        end
      end
    end

    context "#templates_for" do
      setup do
        @mapping.register Stub, 'a'
        @mapping.register Stub2, 'b'
      end

      test "handles multiple engines" do
        assert_equal [Stub2, Stub], @mapping.templates_for('hello/world.a.b')
      end
    end
  end
end

