#!/usr/bin/env ruby

#--
# Portions copyright 2011 by Bart ten Brinke (info@retrosync.com).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#++

require 'helper'
require 'preload'
require 'builder'

class TestMethodCaching < Builder::Test

  # We can directly ask if xml object responds to the cache_me or
  # do_not_cache_me methods because xml is derived from BasicObject
  # (and repond_to? is not defined in BasicObject).
  #
  # Instead we are going to stub out method_missing so that it throws
  # an error, and then make sure that error is either thrown or not
  # thrown as appropriate.

  def teardown
    super
    Builder::XmlBase.cache_method_calls = true
  end

  def test_caching_does_not_break_weird_symbols
    xml = Builder::XmlMarkup.new
    xml.__send__("work-order", 1)
    assert_equal "<work-order>1</work-order>", xml.target!
  end

  def test_method_call_caching
    xml = Builder::XmlMarkup.new
    xml.cache_me

    def xml.method_missing(*args)
      ::Kernel.fail StandardError, "SHOULD NOT BE CALLED"
    end
    assert_nothing_raised do
      xml.cache_me
    end
  end

  def test_method_call_caching_disabled
    Builder::XmlBase.cache_method_calls = false
    xml = Builder::XmlMarkup.new
    xml.do_not_cache_me

    def xml.method_missing(*args)
      ::Kernel.fail StandardError, "SHOULD BE CALLED"
    end
    assert_raise(StandardError, "SHOULD BE CALLED") do
      xml.do_not_cache_me
    end
  end

end
