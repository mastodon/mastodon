#!/usr/bin/env ruby

#--
# Portions copyright 2004 by Jim Weirich (jim@weirichhouse.org).
# Portions copyright 2005 by Sam Ruby (rubys@intertwingly.net).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#++

require 'helper'
require 'preload'
require 'blankslate'
require 'stringio'

# Methods to be introduced into the Object class late.
module LateObject
  def late_object
    33
  end
  def LateObject.included(mod)
    # Modules defining an included method should not prevent blank
    # slate erasure!
  end
end

# Methods to be introduced into the Kernel module late.
module LateKernel
  def late_kernel
    44
  end
  def LateKernel.included(mod)
    # Modules defining an included method should not prevent blank
    # slate erasure!
  end
end

# Introduce some late methods (both module and direct) into the Kernel
# module.
module Kernel
  include LateKernel

  def late_addition
    1234
  end

  def double_late_addition
    22
  end
end


# Introduce some late methods (both module and direct) into the Object
# class.
class Object
  include LateObject
  def another_late_addition
    4321
  end
end

# Introduce some late methods by inclusion.
module GlobalModule
 def global_inclusion
   42
 end
end
include GlobalModule

def direct_global
  43
end

######################################################################
# Test case for blank slate.
#
class TestBlankSlate < Builder::Test
  def setup
    @bs = BlankSlate.new
  end

  def test_undefined_methods_remain_undefined
    assert_raise(NoMethodError) { @bs.no_such_method }
    assert_raise(NoMethodError) { @bs.nil? }
  end


  # NOTE: NameError is acceptable because the lack of a '.' means that
  # Ruby can't tell if it is a method or a local variable.
  def test_undefined_methods_remain_undefined_during_instance_eval
    assert_raise(NoMethodError, NameError)  do
      @bs.instance_eval do nil? end
    end
    assert_raise(NoMethodError, NameError)  do
      @bs.instance_eval do no_such_method end
    end
  end

  def test_private_methods_are_undefined
    assert_raise(NoMethodError) do
      @bs.puts "HI"
    end
  end

  def test_targetted_private_methods_are_undefined_during_instance_eval
    assert_raise(NoMethodError, NameError) do
      @bs.instance_eval do self.puts "HI" end
    end
  end

  def test_untargetted_private_methods_are_defined_during_instance_eval
    oldstdout = $stdout
    $stdout = StringIO.new
    @bs.instance_eval do
      puts "HI"
    end
  ensure
    $stdout = oldstdout
  end

  def test_methods_added_late_to_kernel_remain_undefined
    assert_equal 1234, nil.late_addition
    assert_raise(NoMethodError) { @bs.late_addition }
  end

  def test_methods_added_late_to_object_remain_undefined
    assert_equal 4321, nil.another_late_addition
    assert_raise(NoMethodError) { @bs.another_late_addition }
  end

  def test_methods_added_late_to_global_remain_undefined
    assert_equal 42, global_inclusion
    assert_raise(NoMethodError) { @bs.global_inclusion }
  end

  def test_preload_method_added
    assert Kernel.k_added_names.include?(:late_addition)
    assert Object.o_added_names.include?(:another_late_addition)
  end

  def test_method_defined_late_multiple_times_remain_undefined
    assert_equal 22, nil.double_late_addition
    assert_raise(NoMethodError) { @bs.double_late_addition }
  end

  def test_late_included_module_in_object_is_ok
    assert_equal 33, 1.late_object
    assert_raise(NoMethodError) { @bs.late_object }
  end

  def test_late_included_module_in_kernel_is_ok
    assert_raise(NoMethodError) { @bs.late_kernel }
  end

  def test_revealing_previously_hidden_methods_are_callable
    with_to_s = Class.new(BlankSlate) do
      reveal :to_s
    end
    assert_match(/^#<.*>$/, with_to_s.new.to_s)
  end

  def test_revealing_previously_hidden_methods_are_callable_with_block
    Object.class_eval <<-EOS
      def given_block(&block)
        block
      end
    EOS

    with_given_block = Class.new(BlankSlate) do
      reveal :given_block
    end
    assert_not_nil with_given_block.new.given_block {}
  end

  def test_revealing_a_hidden_method_twice_is_ok
    with_to_s = Class.new(BlankSlate) do
      reveal :to_s
      reveal :to_s
    end
    assert_match(/^#<.*>$/, with_to_s.new.to_s)
  end

  def test_revealing_unknown_hidden_method_is_an_error
    assert_raises(RuntimeError) do
      Class.new(BlankSlate) do
        reveal :xyz
      end
    end
  end

  def test_global_includes_still_work
    assert_nothing_raised do
      assert_equal 42, global_inclusion
      assert_equal 42, Object.new.global_inclusion
      assert_equal 42, "magic number".global_inclusion
      assert_equal 43, direct_global
    end
  end

  def test_reveal_should_not_bind_to_an_instance
    with_object_id = Class.new(BlankSlate) do
      reveal(:object_id)
    end

    obj1 = with_object_id.new
    obj2 = with_object_id.new

    assert obj1.object_id != obj2.object_id,
       "Revealed methods should not be bound to a particular instance"
  end
end
