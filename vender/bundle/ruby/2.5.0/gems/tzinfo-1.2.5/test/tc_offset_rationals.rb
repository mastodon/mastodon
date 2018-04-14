require File.join(File.expand_path(File.dirname(__FILE__)), 'test_utils')

include TZInfo

class TCOffsetRationals < Minitest::Test
  def test_rational_for_offset
    [0,1,2,3,4,-1,-2,-3,-4,30*60,-30*60,61*60,-61*60,14*60*60,-14*60*60,20*60*60,-20*60*60].each {|seconds|
      assert_equal(Rational(seconds, 86400), OffsetRationals.rational_for_offset(seconds))      
    }
  end
  
  def test_rational_for_offset_constant
    -28.upto(28) {|i|
      seconds = i * 30 * 60
      
      r1 = OffsetRationals.rational_for_offset(seconds)
      r2 = OffsetRationals.rational_for_offset(seconds)
      
      assert_equal(Rational(seconds, 86400), r1)
      assert_same(r1, r2)
    }
  end
end
