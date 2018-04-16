#!/usr/bin/env ruby

#--
# Portions copyright 2004 by Jim Weirich (jim@weirichhouse.org).
# Portions copyright 2005 by Sam Ruby (rubys@intertwingly.net).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#++

# We are defining method_added in Kernel and Object so that when
# BlankSlate overrides them later, we can verify that it correctly
# calls the older hooks.

module Kernel
  class << self
    attr_reader :k_added_names
    alias_method :preload_method_added, :method_added
    def method_added(name)
      preload_method_added(name)
      @k_added_names ||= []
      @k_added_names << name
    end
  end
end

class Object
  class << self
    attr_reader :o_added_names
    alias_method :preload_method_added, :method_added
    def method_added(name)
      preload_method_added(name)
      @o_added_names ||= []
      @o_added_names << name
    end
  end
end
