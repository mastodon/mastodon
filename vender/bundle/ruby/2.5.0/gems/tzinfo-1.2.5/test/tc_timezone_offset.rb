require File.join(File.expand_path(File.dirname(__FILE__)), 'test_utils')

include TZInfo

class TCTimezoneOffset < Minitest::Test
  
  def test_utc_offset
    o1 = TimezoneOffset.new(18000, 0, :TEST)
    o2 = TimezoneOffset.new(-3600, 3600, :TEST2)
    
    assert_equal(18000, o1.utc_offset)
    assert_equal(-3600, o2.utc_offset)
  end
  
  def test_std_offset
    o1 = TimezoneOffset.new(18000, 0, :TEST)
    o2 = TimezoneOffset.new(-3600, 3600, :TEST2)
    
    assert_equal(0, o1.std_offset)
    assert_equal(3600, o2.std_offset)
  end
  
  def test_utc_total_offset
    o1 = TimezoneOffset.new(18000, 0, :TEST)
    o2 = TimezoneOffset.new(-3600, 3600, :TEST2)
    
    assert_equal(18000, o1.utc_total_offset)
    assert_equal(0, o2.utc_total_offset)
  end
  
  def test_abbreviation
    o1 = TimezoneOffset.new(18000, 0, :TEST)
    o2 = TimezoneOffset.new(-3600, 3600, :TEST2)
    
    assert_equal(:TEST, o1.abbreviation)
    assert_equal(:TEST2, o2.abbreviation)
  end
  
  def test_dst
    o1 = TimezoneOffset.new(18000, 0, :TEST)
    o2 = TimezoneOffset.new(-3600, 3600, :TEST2)
    
    assert_equal(false, o1.dst?)
    assert_equal(true, o2.dst?)
  end
  
  def test_to_local
    o1 = TimezoneOffset.new(18000, 0, :TEST)
    o2 = TimezoneOffset.new(-3600, 3600, :TEST2)
    
    assert_equal(1148949080, o1.to_local(1148931080))
    assert_equal(Time.utc(2006, 5, 30, 0, 31, 20), o1.to_local(Time.utc(2006, 5, 29, 19, 31, 20)))
    assert_equal(Time.utc(2006, 5, 30, 0, 31, 20, 782000), o1.to_local(Time.utc(2006, 5, 29, 19, 31, 20, 782000)))
    assert_equal(DateTime.new(2006, 5, 30, 0, 31, 20), o1.to_local(DateTime.new(2006, 5, 29, 19, 31, 20)))
    assert_equal(DateTime.new(2006, 5, 30, 0, 31, 20 + Rational(782, 1000)), o1.to_local(DateTime.new(2006, 5, 29, 19, 31, 20 + Rational(782, 1000))))
    assert_equal(1148949080, o1.to_local(1148931080))
    assert(TimeOrDateTime.new(1148949080).eql?(o1.to_local(TimeOrDateTime.new(1148931080))))
    
    assert_equal(1148931080, o2.to_local(1148931080))
    assert_equal(Time.utc(2006, 5, 29, 19, 31, 20), o2.to_local(Time.utc(2006, 5, 29, 19, 31, 20)))
    assert_equal(Time.utc(2006, 5, 29, 19, 31, 20, 123000), o2.to_local(Time.utc(2006, 5, 29, 19, 31, 20, 123000)))
    assert_equal(DateTime.new(2006, 5, 29, 19, 31, 20), o2.to_local(DateTime.new(2006, 5, 29, 19, 31, 20)))
    assert_equal(DateTime.new(2006, 5, 29, 19, 31, 20 + Rational(123, 1000)), o2.to_local(DateTime.new(2006, 5, 29, 19, 31, 20 + Rational(123, 1000))))
    assert_equal(1148931080, o2.to_local(1148931080))
    assert(TimeOrDateTime.new(1148931080).eql?(o2.to_local(TimeOrDateTime.new(1148931080))))
  end
  
  def test_to_utc
    o1 = TimezoneOffset.new(18000, 0, :TEST)
    o2 = TimezoneOffset.new(-3600, 3600, :TEST2)
    
    assert_equal(1148913080, o1.to_utc(1148931080))
    assert_equal(Time.utc(2006, 5, 29, 14, 31, 20), o1.to_utc(Time.utc(2006, 5, 29, 19, 31, 20)))
    assert_equal(Time.utc(2006, 5, 29, 14, 31, 20, 913000), o1.to_utc(Time.utc(2006, 5, 29, 19, 31, 20, 913000)))
    assert_equal(DateTime.new(2006, 5, 29, 14, 31, 20), o1.to_utc(DateTime.new(2006, 5, 29, 19, 31, 20)))
    assert_equal(DateTime.new(2006, 5, 29, 14, 31, 20 + Rational(913,1000)), o1.to_utc(DateTime.new(2006, 5, 29, 19, 31, 20 + Rational(913,1000))))
    assert_equal(1148913080, o1.to_utc(1148931080))
    assert(TimeOrDateTime.new(1148913080).eql?(o1.to_utc(TimeOrDateTime.new(1148931080))))
    
    assert_equal(1148931080, o2.to_local(1148931080))
    assert_equal(Time.utc(2006, 5, 29, 19, 31, 20), o2.to_local(Time.utc(2006, 5, 29, 19, 31, 20)))
    assert_equal(Time.utc(2006, 5, 29, 19, 31, 20, 323000), o2.to_local(Time.utc(2006, 5, 29, 19, 31, 20, 323000)))
    assert_equal(DateTime.new(2006, 5, 29, 19, 31, 20), o2.to_local(DateTime.new(2006, 5, 29, 19, 31, 20)))
    assert_equal(DateTime.new(2006, 5, 29, 19, 31, 20 + Rational(323, 1000)), o2.to_local(DateTime.new(2006, 5, 29, 19, 31, 20 + Rational(323, 1000))))
    assert_equal(1148931080, o2.to_utc(1148931080))
    assert(TimeOrDateTime.new(1148931080).eql?(o2.to_local(TimeOrDateTime.new(1148931080))))    
  end
  
  def test_equality
    o1 = TimezoneOffset.new(18000, 0, :TEST)
    o2 = TimezoneOffset.new(18000, 0, :TEST)
    o3 = TimezoneOffset.new(18001, 0, :TEST)
    o4 = TimezoneOffset.new(18000, 1, :TEST)
    o5 = TimezoneOffset.new(18000, 0, :TEST2)
    
    assert_equal(true, o1 == o1)
    assert_equal(true, o1 == o2)
    assert_equal(false, o1 == o3)
    assert_equal(false, o1 == o4)
    assert_equal(false, o1 == o5)
    assert_equal(false, o1 == Object.new)
  end
  
  def test_eql
    o1 = TimezoneOffset.new(18000, 0, :TEST)
    o2 = TimezoneOffset.new(18000, 0, :TEST)
    o3 = TimezoneOffset.new(18001, 0, :TEST)
    o4 = TimezoneOffset.new(18000, 1, :TEST)
    o5 = TimezoneOffset.new(18000, 0, :TEST2)
    
    assert_equal(true, o1.eql?(o1))
    assert_equal(true, o1.eql?(o2))
    assert_equal(false, o1.eql?(o3))
    assert_equal(false, o1.eql?(o4))
    assert_equal(false, o1.eql?(o5))
    assert_equal(false, o1.eql?(Object.new))
  end
  
  def test_hash
    o1 = TimezoneOffset.new(18000, 0, :TEST)
    o2 = TimezoneOffset.new(-3600, 3600, :TEST2)
    
    assert_equal(18000.hash ^ 0.hash ^ :TEST.hash, o1.hash)
    assert_equal(-3600.hash ^ 3600.hash ^ :TEST2.hash, o2.hash)
  end
end
