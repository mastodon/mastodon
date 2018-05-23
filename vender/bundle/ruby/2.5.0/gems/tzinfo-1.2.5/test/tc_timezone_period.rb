require File.join(File.expand_path(File.dirname(__FILE__)), 'test_utils')

include TZInfo

class TCTimezonePeriod < Minitest::Test
  
  class TestTimezoneTransition < TimezoneTransition
    def initialize(offset, previous_offset, at)
      super(offset, previous_offset)
      @at = TimeOrDateTime.wrap(at)
    end
    
    def at
      @at
    end
  end
  
  def test_initialize_start_end
    std = TimezoneOffset.new(-7200, 0, :TEST)
    dst = TimezoneOffset.new(-7200, 3600, :TEST)
    start_t = TestTimezoneTransition.new(dst, std, 1136073600)
    end_t = TestTimezoneTransition.new(std, dst, 1136160000)
      
    p = TimezonePeriod.new(start_t, end_t)
    
    assert_same(start_t, p.start_transition)
    assert_same(end_t, p.end_transition)
    assert_same(dst, p.offset)
    assert_equal(DateTime.new(2006,1,1,0,0,0), p.utc_start)
    assert_equal(Time.utc(2006,1,1,0,0,0), p.utc_start_time)
    assert_equal(DateTime.new(2006,1,2,0,0,0), p.utc_end)
    assert_equal(Time.utc(2006,1,2,0,0,0), p.utc_end_time)
    assert_equal(-7200, p.utc_offset)
    assert_equal(3600, p.std_offset)
    assert_equal(-3600, p.utc_total_offset)
    assert_equal(Rational(-3600, 86400), p.utc_total_offset_rational)
    assert_equal(:TEST, p.zone_identifier)
    assert_equal(:TEST, p.abbreviation)    
    assert_equal(DateTime.new(2005,12,31,23,0,0), p.local_start)
    assert_equal(Time.utc(2005,12,31,23,0,0), p.local_start_time)
    assert_equal(DateTime.new(2006,1,1,23,0,0), p.local_end)
    assert_equal(Time.utc(2006,1,1,23,0,0), p.local_end_time)
  end
  
  def test_initialize_start_end_offset
    std = TimezoneOffset.new(-7200, 0, :TEST)
    dst = TimezoneOffset.new(-7200, 3600, :TEST)
    special = TimezoneOffset.new(0, 0, :SPECIAL)
    start_t = TestTimezoneTransition.new(dst, std, 1136073600)
    end_t = TestTimezoneTransition.new(std, dst, 1136160000)
      
    assert_raises(ArgumentError) { TimezonePeriod.new(start_t, end_t, special) }
  end
  
  def test_initialize_start
    std = TimezoneOffset.new(-7200, 0, :TEST)
    dst = TimezoneOffset.new(-7200, 3600, :TEST)
    start_t = TestTimezoneTransition.new(dst, std, 1136073600)
      
    p = TimezonePeriod.new(start_t, nil)
    
    assert_same(start_t, p.start_transition)
    assert_nil(p.end_transition)
    assert_same(dst, p.offset)
    assert_equal(DateTime.new(2006,1,1,0,0,0), p.utc_start)
    assert_equal(Time.utc(2006,1,1,0,0,0), p.utc_start_time)
    assert_nil(p.utc_end)
    assert_nil(p.utc_end_time)
    assert_equal(-7200, p.utc_offset)
    assert_equal(3600, p.std_offset)
    assert_equal(-3600, p.utc_total_offset)
    assert_equal(Rational(-3600, 86400), p.utc_total_offset_rational)
    assert_equal(:TEST, p.zone_identifier)
    assert_equal(:TEST, p.abbreviation)    
    assert_equal(DateTime.new(2005,12,31,23,0,0), p.local_start)
    assert_equal(Time.utc(2005,12,31,23,0,0), p.local_start_time)
    assert_nil(p.local_end)
    assert_nil(p.local_end_time)
  end
  
  def test_initialize_start_offset
    std = TimezoneOffset.new(-7200, 0, :TEST)
    dst = TimezoneOffset.new(-7200, 3600, :TEST)
    special = TimezoneOffset.new(0, 0, :SPECIAL)
    start_t = TestTimezoneTransition.new(dst, std, 1136073600)
      
    assert_raises(ArgumentError) { TimezonePeriod.new(start_t, nil, special) }
  end
  
  def test_initialize_end
    std = TimezoneOffset.new(-7200, 0, :TEST)
    dst = TimezoneOffset.new(-7200, 3600, :TEST)    
    end_t = TestTimezoneTransition.new(std, dst, 1136160000)
      
    p = TimezonePeriod.new(nil, end_t)
    
    assert_nil(p.start_transition)
    assert_same(end_t, p.end_transition)
    assert_same(dst, p.offset)
    assert_nil(p.utc_start)
    assert_nil(p.utc_start_time)
    assert_equal(DateTime.new(2006,1,2,0,0,0), p.utc_end)
    assert_equal(Time.utc(2006,1,2,0,0,0), p.utc_end_time)
    assert_equal(-7200, p.utc_offset)
    assert_equal(3600, p.std_offset)
    assert_equal(-3600, p.utc_total_offset)
    assert_equal(Rational(-3600, 86400), p.utc_total_offset_rational)
    assert_equal(:TEST, p.zone_identifier)
    assert_equal(:TEST, p.abbreviation)    
    assert_nil(p.local_start)
    assert_nil(p.local_start_time)
    assert_equal(DateTime.new(2006,1,1,23,0,0), p.local_end)
    assert_equal(Time.utc(2006,1,1,23,0,0), p.local_end_time)
  end
  
  def test_initialize_end_offset
    std = TimezoneOffset.new(-7200, 0, :TEST)
    dst = TimezoneOffset.new(-7200, 3600, :TEST)    
    special = TimezoneOffset.new(0, 0, :SPECIAL)
    end_t = TestTimezoneTransition.new(std, dst, 1136160000)
      
    assert_raises(ArgumentError) { TimezonePeriod.new(nil, end_t, special) }    
  end
  
  def test_initialize
    assert_raises(ArgumentError) { TimezonePeriod.new(nil, nil) }
  end
  
  def test_initialize_offset
    special = TimezoneOffset.new(0, 0, :SPECIAL)
      
    p = TimezonePeriod.new(nil, nil, special)
    
    assert_nil(p.start_transition)
    assert_nil(p.end_transition)
    assert_same(special, p.offset)
    assert_nil(p.utc_start)
    assert_nil(p.utc_start_time)
    assert_nil(p.utc_end)
    assert_nil(p.utc_end_time)
    assert_equal(0, p.utc_offset)
    assert_equal(0, p.std_offset)
    assert_equal(0, p.utc_total_offset)
    assert_equal(Rational(0, 86400), p.utc_total_offset_rational)
    assert_equal(:SPECIAL, p.zone_identifier)
    assert_equal(:SPECIAL, p.abbreviation)    
    assert_nil(p.local_start)
    assert_nil(p.local_start_time)
    assert_nil(p.local_end)
    assert_nil(p.local_end_time)
  end

  def test_utc_total_offset_rational_after_freeze
    o = TimezoneOffset.new(3600, 0, :TEST)
    p = TimezonePeriod.new(nil, nil, o)
    p.freeze
    assert_equal(Rational(1, 24), p.utc_total_offset_rational)
  end
  
  def test_dst    
    p1 = TimezonePeriod.new(nil, nil, TimezoneOffset.new(-14400, 3600, :TEST))
    p2 = TimezonePeriod.new(nil, nil, TimezoneOffset.new(-14400, 0, :TEST))
    p3 = TimezonePeriod.new(nil, nil, TimezoneOffset.new(-14400, -3600, :TEST))
    p4 = TimezonePeriod.new(nil, nil, TimezoneOffset.new(-14400, 7200, :TEST))
    p5 = TimezonePeriod.new(nil, nil, TimezoneOffset.new(-14400, -7200, :TEST))
    
    assert_equal(true, p1.dst?)
    assert_equal(false, p2.dst?)
    assert_equal(true, p3.dst?)
    assert_equal(true, p4.dst?)
    assert_equal(true, p5.dst?)
  end
  
  def test_valid_for_utc
    offset = TimezoneOffset.new(-7200, 3600, :TEST)
    t1 = TestTimezoneTransition.new(offset, offset, 1104541261)
    t2 = TestTimezoneTransition.new(offset, offset, 1107309722)
    t3 = TestTimezoneTransition.new(offset, offset, DateTime.new(1960, 1, 1, 1, 1, 1))
    t4 = TestTimezoneTransition.new(offset, offset, DateTime.new(1960, 2, 2, 2, 2, 2))
    
    p1 = TimezonePeriod.new(t1, t2)
    p2 = TimezonePeriod.new(nil, t2)
    p3 = TimezonePeriod.new(t1, nil)
    p4 = TimezonePeriod.new(nil, nil, offset)
    p5 = TimezonePeriod.new(t3, t4)
    
    assert_equal(true, p1.valid_for_utc?(DateTime.new(2005,1,1,1,1,1)))
    assert_equal(true, p1.valid_for_utc?(Time.utc(2005,2,2,2,2,1)))
    assert_equal(true, p1.valid_for_utc?(1104541262))
    assert_equal(true, p1.valid_for_utc?(DateTime.new(2005,2,2,2,2,0)))
    assert_equal(false, p1.valid_for_utc?(DateTime.new(2005,1,1,1,1,0)))
    assert_equal(false, p1.valid_for_utc?(DateTime.new(2005,2,2,2,2,3)))
    assert_equal(false, p1.valid_for_utc?(DateTime.new(1960,1,1,1,1,0)))
    assert_equal(false, p1.valid_for_utc?(DateTime.new(2040,1,1,1,1,0)))
    
    assert_equal(true, p2.valid_for_utc?(DateTime.new(2005,1,1,1,1,1)))
    assert_equal(true, p2.valid_for_utc?(Time.utc(2005,2,2,2,2,1)))
    assert_equal(true, p2.valid_for_utc?(1104541262))
    assert_equal(true, p2.valid_for_utc?(DateTime.new(2005,2,2,2,2,0)))
    assert_equal(true, p2.valid_for_utc?(DateTime.new(2005,1,1,1,1,0)))    
    assert_equal(false, p2.valid_for_utc?(DateTime.new(2005,2,2,2,2,3)))
    assert_equal(true, p2.valid_for_utc?(DateTime.new(1960,1,1,1,1,0)))
    assert_equal(false, p2.valid_for_utc?(DateTime.new(2040,1,1,1,1,0)))
    
    assert_equal(true, p3.valid_for_utc?(DateTime.new(2005,1,1,1,1,1)))
    assert_equal(true, p3.valid_for_utc?(Time.utc(2005,2,2,2,2,1)))
    assert_equal(true, p3.valid_for_utc?(1104541262))
    assert_equal(true, p3.valid_for_utc?(DateTime.new(2005,2,2,2,2,0)))
    assert_equal(false, p3.valid_for_utc?(DateTime.new(2005,1,1,1,1,0)))
    assert_equal(true, p3.valid_for_utc?(DateTime.new(2005,2,2,2,2,3)))
    assert_equal(false, p3.valid_for_utc?(DateTime.new(1960,1,1,1,1,0)))
    assert_equal(true, p3.valid_for_utc?(DateTime.new(2040,1,1,1,1,0)))
    
    assert_equal(true, p4.valid_for_utc?(DateTime.new(2005,1,1,1,1,1)))
    assert_equal(true, p4.valid_for_utc?(Time.utc(2005,2,2,2,2,1)))
    assert_equal(true, p4.valid_for_utc?(1104541262))
    assert_equal(true, p4.valid_for_utc?(DateTime.new(2005,2,2,2,2,0)))
    assert_equal(true, p4.valid_for_utc?(DateTime.new(2005,1,1,1,1,0)))
    assert_equal(true, p4.valid_for_utc?(DateTime.new(2005,2,2,2,2,3)))
    assert_equal(true, p4.valid_for_utc?(DateTime.new(1960,1,1,1,1,0)))
    assert_equal(true, p4.valid_for_utc?(DateTime.new(2040,1,1,1,1,0)))
    
    assert_equal(false, p5.valid_for_utc?(Time.utc(2005,1,1,1,1,1)))
    assert_equal(false, p5.valid_for_utc?(1104541262))
  end
  
  def test_utc_after_start
    offset = TimezoneOffset.new(-7200, 3600, :TEST)
    t1 = TestTimezoneTransition.new(offset, offset, 1104541261)
    t2 = TestTimezoneTransition.new(offset, offset, 1107309722)
    t3 = TestTimezoneTransition.new(offset, offset, DateTime.new(1945, 1, 1, 1, 1, 1))
    t4 = TestTimezoneTransition.new(offset, offset, DateTime.new(1945, 2, 2, 2, 2, 2))
    
    p1 = TimezonePeriod.new(t1, t2)
    p2 = TimezonePeriod.new(nil, t2)
    p3 = TimezonePeriod.new(t3, t4)

    assert_equal(true, p1.utc_after_start?(DateTime.new(2005,1,1,1,1,1)))    
    assert_equal(true, p1.utc_after_start?(Time.utc(2005,1,1,1,1,2)))
    assert_equal(false, p1.utc_after_start?(1104541260))
    assert_equal(true, p1.utc_after_start?(DateTime.new(2045,1,1,1,1,0)))
    assert_equal(false, p1.utc_after_start?(DateTime.new(1955,1,1,1,1,0)))

    assert_equal(true, p2.utc_after_start?(DateTime.new(2005,1,1,1,1,1)))    
    assert_equal(true, p2.utc_after_start?(Time.utc(2005,1,1,1,1,2)))
    assert_equal(true, p2.utc_after_start?(1104541260)) 
    
    assert_equal(true, p3.utc_after_start?(Time.utc(2005,1,2,1,1,1)))
    assert_equal(true, p3.utc_after_start?(1104627661))
  end
  
  def test_utc_before_end
    offset = TimezoneOffset.new(-7200, 3600, :TEST)
    t1 = TestTimezoneTransition.new(offset, offset, 1104541261)
    t2 = TestTimezoneTransition.new(offset, offset, 1107309722)
    t3 = TestTimezoneTransition.new(offset, offset, DateTime.new(1945, 1, 1, 1, 1, 1))
    t4 = TestTimezoneTransition.new(offset, offset, DateTime.new(1945, 2, 2, 2, 2, 2))
    
    p1 = TimezonePeriod.new(t1, t2)
    p2 = TimezonePeriod.new(t1, nil)
    p3 = TimezonePeriod.new(t3, t4)
    
    assert_equal(true, p1.utc_before_end?(DateTime.new(2005,2,2,2,2,1)))    
    assert_equal(true, p1.utc_before_end?(Time.utc(2005,2,2,2,2,0)))   
    assert_equal(false, p1.utc_before_end?(1107309723))
    assert_equal(false, p1.utc_before_end?(DateTime.new(2045,1,1,1,1,0)))
    assert_equal(true, p1.utc_before_end?(DateTime.new(1955,1,1,1,1,0)))
    
    assert_equal(true, p2.utc_before_end?(DateTime.new(2005,2,2,2,2,1)))    
    assert_equal(true, p2.utc_before_end?(Time.utc(2005,2,2,2,2,0)))   
    assert_equal(true, p2.utc_before_end?(1107309723))
    
    assert_equal(false, p3.utc_before_end?(Time.utc(2005,1,2,1,1,1)))
    assert_equal(false, p3.utc_before_end?(1104627661))
  end
  
  def test_valid_for_local
    offset = TimezoneOffset.new(-7200, 3600, :TEST)
    t1 = TestTimezoneTransition.new(offset, offset, 1104544861)
    t2 = TestTimezoneTransition.new(offset, offset, 1107313322)
    t3 = TestTimezoneTransition.new(offset, offset, 1104544861)
    t4 = TestTimezoneTransition.new(offset, offset, DateTime.new(1960, 1, 1, 1, 1, 1))
    t5 = TestTimezoneTransition.new(offset, offset, DateTime.new(1960, 2, 2, 2, 2, 2))
    
    p1 = TimezonePeriod.new(t1, t2)
    p2 = TimezonePeriod.new(nil, t2)
    p3 = TimezonePeriod.new(t3, nil)
    p4 = TimezonePeriod.new(nil, nil, offset)
    p5 = TimezonePeriod.new(t4, t5)
    
    assert_equal(true, p1.valid_for_local?(DateTime.new(2005,1,1,1,1,1)))
    assert_equal(true, p1.valid_for_local?(Time.utc(2005,2,2,2,2,1)))
    assert_equal(true, p1.valid_for_local?(1104541262))
    assert_equal(true, p1.valid_for_local?(DateTime.new(2005,2,2,2,2,0)))
    assert_equal(false, p1.valid_for_local?(DateTime.new(2005,1,1,1,1,0)))
    assert_equal(false, p1.valid_for_local?(DateTime.new(2005,2,2,2,2,3)))
    assert_equal(false, p1.valid_for_local?(DateTime.new(1960,1,1,1,1,0)))
    assert_equal(false, p1.valid_for_local?(DateTime.new(2040,1,1,1,1,0)))
    
    assert_equal(true, p2.valid_for_local?(DateTime.new(2005,1,1,1,1,1)))
    assert_equal(true, p2.valid_for_local?(DateTime.new(2005,2,2,2,2,1)))
    assert_equal(true, p2.valid_for_local?(1104541262))
    assert_equal(true, p2.valid_for_local?(DateTime.new(2005,2,2,2,2,0)))
    assert_equal(true, p2.valid_for_local?(DateTime.new(2005,1,1,1,1,0)))
    assert_equal(false, p2.valid_for_local?(DateTime.new(2005,2,2,2,2,3)))
    assert_equal(true, p2.valid_for_local?(DateTime.new(1960,1,1,1,1,0)))
    assert_equal(false, p2.valid_for_local?(DateTime.new(2040,1,1,1,1,0)))
    
    assert_equal(true, p3.valid_for_local?(DateTime.new(2005,1,1,1,1,1)))
    assert_equal(true, p3.valid_for_local?(DateTime.new(2005,2,2,2,2,1)))
    assert_equal(true, p3.valid_for_local?(1104541262))
    assert_equal(true, p3.valid_for_local?(DateTime.new(2005,2,2,2,2,0)))
    assert_equal(false, p3.valid_for_local?(DateTime.new(2005,1,1,1,1,0)))
    assert_equal(true, p3.valid_for_local?(DateTime.new(2005,2,2,2,2,3)))
    assert_equal(false, p3.valid_for_local?(DateTime.new(1960,1,1,1,1,0)))
    assert_equal(true, p3.valid_for_local?(DateTime.new(2040,1,1,1,1,0)))
    
    assert_equal(true, p4.valid_for_local?(DateTime.new(2005,1,1,1,1,1)))
    assert_equal(true, p4.valid_for_local?(DateTime.new(2005,2,2,2,2,1)))
    assert_equal(true, p4.valid_for_local?(1104541262))
    assert_equal(true, p4.valid_for_local?(DateTime.new(2005,2,2,2,2,0)))
    assert_equal(true, p4.valid_for_local?(DateTime.new(2005,1,1,1,1,0)))
    assert_equal(true, p4.valid_for_local?(DateTime.new(2005,2,2,2,2,3)))
    assert_equal(true, p4.valid_for_local?(DateTime.new(1960,1,1,1,1,0)))
    assert_equal(true, p4.valid_for_local?(DateTime.new(2040,1,1,1,1,0)))
    
    assert_equal(false, p5.valid_for_utc?(Time.utc(2005,1,1,1,1,1)))
    assert_equal(false, p5.valid_for_utc?(1104541262))
  end
  
  def test_local_after_start
    offset = TimezoneOffset.new(-7200, 3600, :TEST)
    t1 = TestTimezoneTransition.new(offset, offset, 1104544861)
    t2 = TestTimezoneTransition.new(offset, offset, 1107313322)
    t3 = TestTimezoneTransition.new(offset, offset, DateTime.new(1945, 1, 1, 1, 1, 1))
    t4 = TestTimezoneTransition.new(offset, offset, DateTime.new(1945, 2, 2, 2, 2, 2))
    
    p1 = TimezonePeriod.new(t1, t2)
    p2 = TimezonePeriod.new(nil, t2)
    p3 = TimezonePeriod.new(t3, t4)

    assert_equal(true, p1.local_after_start?(DateTime.new(2005,1,1,1,1,1)))    
    assert_equal(true, p1.local_after_start?(Time.utc(2005,1,1,1,1,2)))
    assert_equal(false, p1.local_after_start?(1104541260))
    assert_equal(true, p1.local_after_start?(DateTime.new(2045,1,1,1,1,0)))
    assert_equal(false, p1.local_after_start?(DateTime.new(1955,1,1,1,1,0)))

    assert_equal(true, p2.local_after_start?(DateTime.new(2005,1,1,1,1,1)))    
    assert_equal(true, p2.local_after_start?(Time.utc(2005,1,1,1,1,2)))
    assert_equal(true, p2.local_after_start?(1104541260))    
    
    assert_equal(true, p3.local_after_start?(Time.utc(2005,1,2,1,1,1)))
    assert_equal(true, p3.local_after_start?(1104627661))
  end
  
  def test_local_before_end
    offset = TimezoneOffset.new(-7200, 3600, :TEST)
    t1 = TestTimezoneTransition.new(offset, offset, 1104544861)
    t2 = TestTimezoneTransition.new(offset, offset, 1107313322)
    t3 = TestTimezoneTransition.new(offset, offset, DateTime.new(1945, 1, 1, 1, 1, 1))
    t4 = TestTimezoneTransition.new(offset, offset, DateTime.new(1945, 2, 2, 2, 2, 2))
    
    p1 = TimezonePeriod.new(t1, t2)    
    p2 = TimezonePeriod.new(t1, nil)
    p3 = TimezonePeriod.new(t3, t4)    
        
    assert_equal(true, p1.local_before_end?(DateTime.new(2005,2,2,2,2,1)))    
    assert_equal(true, p1.local_before_end?(Time.utc(2005,2,2,2,2,0)))   
    assert_equal(false, p1.local_before_end?(1107309723))
    assert_equal(false, p1.local_before_end?(DateTime.new(2045,1,1,1,1,0)))
    assert_equal(true, p1.local_before_end?(DateTime.new(1955,1,1,1,1,0)))
    
    assert_equal(true, p2.local_before_end?(DateTime.new(2005,2,2,2,2,1)))    
    assert_equal(true, p2.local_before_end?(Time.utc(2005,2,2,2,2,0)))   
    assert_equal(true, p2.local_before_end?(1107309723))
    
    assert_equal(false, p3.local_before_end?(Time.utc(2005,1,2,1,1,1)))
    assert_equal(false, p3.local_before_end?(1104627661))
  end
  
  def test_to_local
    p1 = TimezonePeriod.new(nil, nil, TimezoneOffset.new(-14400, 3600, :TEST))
    p2 = TimezonePeriod.new(nil, nil, TimezoneOffset.new(-14400, 0, :TEST))
    p3 = TimezonePeriod.new(nil, nil, TimezoneOffset.new(7200, 3600, :TEST))
        
    assert_equal(DateTime.new(2005,1,19,22,0,0), p1.to_local(DateTime.new(2005,1,20,1,0,0)))
    assert_equal(DateTime.new(2005,1,19,22,0,0 + Rational(512,1000)), p1.to_local(DateTime.new(2005,1,20,1,0,0 + Rational(512,1000))))
    assert_equal(Time.utc(2005,1,19,21,0,0), p2.to_local(Time.utc(2005,1,20,1,0,0)))
    assert_equal(Time.utc(2005,1,19,21,0,0,512000), p2.to_local(Time.utc(2005,1,20,1,0,0,512000)))
    assert_equal(1106193600, p3.to_local(1106182800))
  end
  
  def test_to_utc
    p1 = TimezonePeriod.new(nil, nil, TimezoneOffset.new(-14400, 3600, :TEST))
    p2 = TimezonePeriod.new(nil, nil, TimezoneOffset.new(-14400, 0, :TEST))
    p3 = TimezonePeriod.new(nil, nil, TimezoneOffset.new(7200, 3600, :TEST))
        
    assert_equal(DateTime.new(2005,1,20,4,0,0), p1.to_utc(DateTime.new(2005,1,20,1,0,0)))
    assert_equal(DateTime.new(2005,1,20,4,0,0 + Rational(571,1000)), p1.to_utc(DateTime.new(2005,1,20,1,0,0 + Rational(571,1000))))
    assert_equal(Time.utc(2005,1,20,5,0,0), p2.to_utc(Time.utc(2005,1,20,1,0,0)))
    assert_equal(Time.utc(2005,1,20,5,0,0,571000), p2.to_utc(Time.utc(2005,1,20,1,0,0,571000)))
    assert_equal(1106172000, p3.to_utc(1106182800))
  end
  
  def test_time_boundary_start
    o1 = TimezoneOffset.new(-3600, 0, :TEST)
    o2 = TimezoneOffset.new(-3600, 3600, :TEST)
    t1 = TestTimezoneTransition.new(o1, o2, 0)
    
    p1 = TimezonePeriod.new(t1, nil)
    
    assert_equal(DateTime.new(1969,12,31,23,0,0), p1.local_start)
    
    # Conversion to Time will fail on systems that don't support negative times.
    if RubyCoreSupport.time_supports_negative
      assert_equal(Time.utc(1969,12,31,23,0,0), p1.local_start_time)
    end
  end
  
  def test_time_boundary_end
    o1 = TimezoneOffset.new(0, 3600, :TEST)
    o2 = TimezoneOffset.new(0, 0, :TEST)
    t1 = TestTimezoneTransition.new(o2, o1, 2147482800)
    
    p1 = TimezonePeriod.new(nil, t1)
    
    assert_equal(DateTime.new(2038,1,19,4,0,0), p1.local_end)
    
    # Conversion to Time will fail on systems that don't support 64-bit times
    if RubyCoreSupport.time_supports_64bit
      assert_equal(Time.utc(2038,1,19,4,0,0), p1.local_end_time)
    end
  end
  
  def test_equality
    o1 = TimezoneOffset.new(0, 3600, :TEST)
    o2 = TimezoneOffset.new(0, 0, :TEST)
    t1 = TestTimezoneTransition.new(o1, o2, 1149368400)
    t2 = TestTimezoneTransition.new(o1, o2, DateTime.new(2006, 6, 3, 21, 0, 0))
    t3 = TestTimezoneTransition.new(o1, o2, 1149454800)
    t4 = TestTimezoneTransition.new(o1, o2, 1149541200)
    
    p1 = TimezonePeriod.new(t1, t3)
    p2 = TimezonePeriod.new(t1, t3)
    p3 = TimezonePeriod.new(t2, t3)
    p4 = TimezonePeriod.new(t3, nil)
    p5 = TimezonePeriod.new(t3, nil)
    p6 = TimezonePeriod.new(t4, nil)
    p7 = TimezonePeriod.new(nil, t3)
    p8 = TimezonePeriod.new(nil, t3)
    p9 = TimezonePeriod.new(nil, t4)
    p10 = TimezonePeriod.new(nil, nil, o1)
    p11 = TimezonePeriod.new(nil, nil, o1)
    p12 = TimezonePeriod.new(nil, nil, o2)
    
    assert_equal(true, p1 == p1)
    assert_equal(true, p1 == p2)
    assert_equal(true, p1 == p3)
    assert_equal(false, p1 == p4)
    assert_equal(false, p1 == p5)
    assert_equal(false, p1 == p6)
    assert_equal(false, p1 == p7)
    assert_equal(false, p1 == p8)
    assert_equal(false, p1 == p9)
    assert_equal(false, p1 == p10)
    assert_equal(false, p1 == p11)
    assert_equal(false, p1 == p12)
    assert_equal(false, p1 == Object.new)
    
    assert_equal(true, p4 == p4)
    assert_equal(true, p4 == p5)
    assert_equal(false, p4 == p6)
    assert_equal(false, p4 == Object.new)
    
    assert_equal(true, p7 == p7)
    assert_equal(true, p7 == p8)
    assert_equal(false, p7 == p9)
    assert_equal(false, p7 == Object.new)
    
    assert_equal(true, p10 == p10)
    assert_equal(true, p10 == p11)
    assert_equal(false, p10 == p12)
    assert_equal(false, p10 == Object.new)
  end
  
  def test_eql
    o1 = TimezoneOffset.new(0, 3600, :TEST)
    o2 = TimezoneOffset.new(0, 0, :TEST)
    t1 = TestTimezoneTransition.new(o1, o2, 1149368400)
    t2 = TestTimezoneTransition.new(o1, o2, DateTime.new(2006, 6, 3, 21, 0, 0))
    t3 = TestTimezoneTransition.new(o1, o2, 1149454800)
    t4 = TestTimezoneTransition.new(o1, o2, 1149541200)
    
    p1 = TimezonePeriod.new(t1, t3)
    p2 = TimezonePeriod.new(t1, t3)
    p3 = TimezonePeriod.new(t2, t3)
    p4 = TimezonePeriod.new(t3, nil)
    p5 = TimezonePeriod.new(t3, nil)
    p6 = TimezonePeriod.new(t4, nil)
    p7 = TimezonePeriod.new(nil, t3)
    p8 = TimezonePeriod.new(nil, t3)
    p9 = TimezonePeriod.new(nil, t4)
    p10 = TimezonePeriod.new(nil, nil, o1)
    p11 = TimezonePeriod.new(nil, nil, o1)
    p12 = TimezonePeriod.new(nil, nil, o2)
    
    assert_equal(true, p1.eql?(p1))
    assert_equal(true, p1.eql?(p2))
    assert_equal(false, p1.eql?(p3))
    assert_equal(false, p1.eql?(p4))
    assert_equal(false, p1.eql?(p5))
    assert_equal(false, p1.eql?(p6))
    assert_equal(false, p1.eql?(p7))
    assert_equal(false, p1.eql?(p8))
    assert_equal(false, p1.eql?(p9))
    assert_equal(false, p1.eql?(p10))
    assert_equal(false, p1.eql?(p11))
    assert_equal(false, p1.eql?(p12))
    assert_equal(false, p1.eql?(Object.new))
    
    assert_equal(true, p4.eql?(p4))
    assert_equal(true, p4.eql?(p5))
    assert_equal(false, p4.eql?(p6))
    assert_equal(false, p4.eql?(Object.new))
    
    assert_equal(true, p7.eql?(p7))
    assert_equal(true, p7.eql?(p8))
    assert_equal(false, p7.eql?(p9))
    assert_equal(false, p7.eql?(Object.new))
    
    assert_equal(true, p10.eql?(p10))
    assert_equal(true, p10.eql?(p11))
    assert_equal(false, p10.eql?(p12))
    assert_equal(false, p10.eql?(Object.new))
  end
  
  def test_hash
    o1 = TimezoneOffset.new(0, 3600, :TEST)
    o2 = TimezoneOffset.new(0, 0, :TEST)
    t1 = TestTimezoneTransition.new(o1, o2, 1149368400)
    t2 = TestTimezoneTransition.new(o1, o2, DateTime.new(2006, 6, 3, 21, 0, 0))
    t3 = TestTimezoneTransition.new(o1, o2, 1149454800)
    t4 = TestTimezoneTransition.new(o1, o2, 1149541200)
    
    p1 = TimezonePeriod.new(t1, t3)    
    p2 = TimezonePeriod.new(t2, nil)
    p3 = TimezonePeriod.new(nil, t4)
    p4 = TimezonePeriod.new(nil, nil, o1)

    assert_equal(t1.hash ^ t3.hash, p1.hash)
    assert_equal(t2.hash ^ nil.hash, p2.hash)
    assert_equal(nil.hash ^ t4.hash, p3.hash)
    assert_equal(nil.hash ^ nil.hash ^ o1.hash, p4.hash)    
  end
end
