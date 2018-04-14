require File.join(File.expand_path(File.dirname(__FILE__)), 'test_utils')

include TZInfo

class TCTransitionDataTimezoneInfo < Minitest::Test
  
  def test_identifier
    dti = TransitionDataTimezoneInfo.new('Test/Zone')
    assert_equal('Test/Zone', dti.identifier)
  end

  def test_offset
    dti = TransitionDataTimezoneInfo.new('Test/Zone')
    
    assert_nothing_raised do
      dti.offset :o1, -18000, 3600, :TEST
    end
  end
  
  def test_offset_already_defined
    dti = TransitionDataTimezoneInfo.new('Test/Zone')
    dti.offset :o1, 3600, 0, :TEST
    dti.offset :o2, 1800, 0, :TEST2
    
    assert_raises(ArgumentError) { dti.offset :o1, 3600, 3600, :TESTD }
  end
  
  def test_transition_timestamp
    dti = TransitionDataTimezoneInfo.new('Test/Zone')
    dti.offset :o1, -18000, 3600, :TEST
    
    assert_nothing_raised do
      dti.transition 2006, 6, :o1, 1149368400
    end
  end
  
  def test_transition_datetime
    dti = TransitionDataTimezoneInfo.new('Test/Zone')
    dti.offset :o1, -18000, 3600, :TEST
    
    assert_nothing_raised do
      dti.transition 2006, 6, :o1, 19631123, 8
    end
  end
  
  def test_transition_timestamp_and_datetime
    dti = TransitionDataTimezoneInfo.new('Test/Zone')
    dti.offset :o1, -18000, 3600, :TEST
    
    assert_nothing_raised do
      dti.transition 2006, 6, :o1, 1149368400, 19631123, 8
    end
  end
  
  def test_transition_invalid_offset
    dti = TransitionDataTimezoneInfo.new('Test/Zone')
    dti.offset :o1, -18000, 3600, :TEST
    
    dti.transition 2006, 6, :o1, 1149368400
    
    assert_raises(ArgumentError) { dti.transition 2006, 6, :o2, 1149454800 }    
  end
  
  def test_transition_no_offsets
    dti = TransitionDataTimezoneInfo.new('Test/Zone')
    
    assert_raises(ArgumentError) { dti.transition 2006, 6, :o1, 1149368400 }
  end
  
  def test_transition_invalid_order_month
    dti = TransitionDataTimezoneInfo.new('Test/Zone')
    dti.offset :o1, -18000, 3600, :TEST
    
    dti.transition 2006, 6, :o1, 1149368400
    
    assert_raises(ArgumentError) { dti.transition 2006, 5, :o2, 1146690000 }
  end
  
  def test_transition_invalid_order_year
    dti = TransitionDataTimezoneInfo.new('Test/Zone')
    dti.offset :o1, -18000, 3600, :TEST
    
    dti.transition 2006, 6, :o1, 1149368400
    
    assert_raises(ArgumentError) { dti.transition 2005, 7, :o2, 1120424400 }
  end   
  
  def test_period_for_utc
    dti = TransitionDataTimezoneInfo.new('Test/Zone')
    dti.offset :o1, -17900,    0, :TESTLMT
    dti.offset :o2, -18000, 3600, :TESTD
    dti.offset :o3, -18000,    0, :TESTS
    dti.offset :o4, -21600, 3600, :TESTD
    
    dti.transition 2000,  4, :o2, Time.utc(2000, 4,1,1,0,0).to_i
    dti.transition 2000, 10, :o3, Time.utc(2000,10,1,1,0,0).to_i
    dti.transition 2001,  3, :o2, 58847269, 24                    # (2001, 3,1,1,0,0)
    dti.transition 2001,  4, :o4, Time.utc(2001, 4,1,1,0,0).to_i, 58848013, 24
    dti.transition 2001, 10, :o3, Time.utc(2001,10,1,1,0,0).to_i
    dti.transition 2002, 10, :o3, Time.utc(2002,10,1,1,0,0).to_i
    dti.transition 2003,  2, :o2, Time.utc(2003, 2,1,1,0,0).to_i
    dti.transition 2003,  3, :o3, Time.utc(2003, 3,1,1,0,0).to_i
    
    o1 = TimezoneOffset.new(-17900, 0,    :TESTLMT)
    o2 = TimezoneOffset.new(-18000, 3600, :TESTD)
    o3 = TimezoneOffset.new(-18000, 0,    :TESTS)
    o4 = TimezoneOffset.new(-21600, 3600, :TESTD)
    
    t1 = TimezoneTransitionDefinition.new(o2, o1, Time.utc(2000, 4,1,1,0,0).to_i)
    t2 = TimezoneTransitionDefinition.new(o3, o2, Time.utc(2000,10,1,1,0,0).to_i)
    t3 = TimezoneTransitionDefinition.new(o2, o3, Time.utc(2001, 3,1,1,0,0).to_i)
    t4 = TimezoneTransitionDefinition.new(o4, o2, Time.utc(2001, 4,1,1,0,0).to_i)
    t5 = TimezoneTransitionDefinition.new(o3, o4, Time.utc(2001,10,1,1,0,0).to_i)
    t6 = TimezoneTransitionDefinition.new(o3, o3, Time.utc(2002,10,1,1,0,0).to_i)
    t7 = TimezoneTransitionDefinition.new(o2, o3, Time.utc(2003, 2,1,1,0,0).to_i)
    t8 = TimezoneTransitionDefinition.new(o3, o2, Time.utc(2003, 3,1,1,0,0).to_i)
    
    assert_equal(TimezonePeriod.new(nil, t1), dti.period_for_utc(DateTime.new(1960, 1,1,1, 0, 0)))
    assert_equal(TimezonePeriod.new(nil, t1), dti.period_for_utc(DateTime.new(1999,12,1,0, 0, 0)))
    assert_equal(TimezonePeriod.new(nil, t1), dti.period_for_utc(Time.utc(    2000, 4,1,0,59,59)))
    assert_equal(TimezonePeriod.new(t1, t2),  dti.period_for_utc(DateTime.new(2000, 4,1,1, 0, 0)))
    assert_equal(TimezonePeriod.new(t1, t2),  dti.period_for_utc(Time.utc(    2000,10,1,0,59,59).to_i))      
    assert_equal(TimezonePeriod.new(t2, t3),  dti.period_for_utc(Time.utc(    2000,10,1,1, 0, 0)))
    assert_equal(TimezonePeriod.new(t2, t3),  dti.period_for_utc(Time.utc(    2001, 3,1,0,59,59)))
    assert_equal(TimezonePeriod.new(t3, t4),  dti.period_for_utc(Time.utc(    2001, 3,1,1, 0, 0)))
    assert_equal(TimezonePeriod.new(t3, t4),  dti.period_for_utc(Time.utc(    2001, 4,1,0,59,59)))
    assert_equal(TimezonePeriod.new(t4, t5),  dti.period_for_utc(Time.utc(    2001, 4,1,1, 0, 0)))
    assert_equal(TimezonePeriod.new(t4, t5),  dti.period_for_utc(Time.utc(    2001,10,1,0,59,59)))
    assert_equal(TimezonePeriod.new(t5, t6),  dti.period_for_utc(Time.utc(    2001,10,1,1, 0, 0)))
    assert_equal(TimezonePeriod.new(t5, t6),  dti.period_for_utc(Time.utc(    2002, 2,1,1, 0, 0)))
    assert_equal(TimezonePeriod.new(t5, t6),  dti.period_for_utc(Time.utc(    2002,10,1,0,59,59)))
    assert_equal(TimezonePeriod.new(t6, t7),  dti.period_for_utc(Time.utc(    2002,10,1,1, 0, 0)))
    assert_equal(TimezonePeriod.new(t6, t7),  dti.period_for_utc(Time.utc(    2003, 2,1,0,59,59)))
    assert_equal(TimezonePeriod.new(t7, t8),  dti.period_for_utc(Time.utc(    2003, 2,1,1, 0, 0)))
    assert_equal(TimezonePeriod.new(t7, t8),  dti.period_for_utc(Time.utc(    2003, 3,1,0,59,59)))
    assert_equal(TimezonePeriod.new(t8, nil), dti.period_for_utc(Time.utc(    2003, 3,1,1, 0, 0)))
    assert_equal(TimezonePeriod.new(t8, nil), dti.period_for_utc(Time.utc(    2004, 1,1,1, 0, 0)))
    assert_equal(TimezonePeriod.new(t8, nil), dti.period_for_utc(DateTime.new(2050, 1,1,1, 0, 0)))        
  end
    
  def test_period_for_utc_no_transitions
    dti = TransitionDataTimezoneInfo.new('Test/Zone')
    dti.offset :o1, -17900, 0, :TESTLMT
    dti.offset :o2, -18000, 0, :TEST
    
    o1 = TimezoneOffset.new(-17900, 0, :TESTLMT)
    
    assert_equal(TimezonePeriod.new(nil, nil, o1), dti.period_for_utc(DateTime.new(2005,1,1,0,0,0)))
    assert_equal(TimezonePeriod.new(nil, nil, o1), dti.period_for_utc(Time.utc(2005,1,1,0,0,0)))
    assert_equal(TimezonePeriod.new(nil, nil, o1), dti.period_for_utc(Time.utc(2005,1,1,0,0,0).to_i))       
  end
    
  def test_period_for_utc_no_offsets
    dti = TransitionDataTimezoneInfo.new('Test/Zone')
    
    assert_raises(NoOffsetsDefined) { dti.period_for_utc(DateTime.new(2005,1,1,0,0,0)) }
    assert_raises(NoOffsetsDefined) { dti.period_for_utc(Time.utc(2005,1,1,0,0,0)) }
    assert_raises(NoOffsetsDefined) { dti.period_for_utc(Time.utc(2005,1,1,0,0,0).to_i) }
  end
  
  def test_periods_for_local
    dti = TransitionDataTimezoneInfo.new('Test/Zone')
    dti.offset :o1, -17900,    0, :TESTLMT
    dti.offset :o2, -18000, 3600, :TESTD
    dti.offset :o3, -18000,    0, :TESTS
    dti.offset :o4, -21600, 3600, :TESTD
    
    dti.transition 2000,  4, :o2, 58839277, 24                   # 2000,4,2,1,0,0
    dti.transition 2000, 10, :o3, Time.utc(2000,10,2,1,0,0).to_i, 58843669, 24
    dti.transition 2001,  3, :o2, Time.utc(2001, 3,2,1,0,0).to_i
    dti.transition 2001,  4, :o4, Time.utc(2001, 4,2,1,0,0).to_i
    dti.transition 2001, 10, :o3, Time.utc(2001,10,2,1,0,0).to_i
    dti.transition 2002, 10, :o3, 58861189, 24                   # 2002,10,2,1,0,0
    dti.transition 2003,  2, :o2, Time.utc(2003, 2,2,1,0,0).to_i
    
    o1 = TimezoneOffset.new(-17900,    0, :TESTLMT)
    o2 = TimezoneOffset.new(-18000, 3600, :TESTD)
    o3 = TimezoneOffset.new(-18000,    0, :TESTS)
    o4 = TimezoneOffset.new(-21600, 3600, :TESTD)
    
    t1 = TimezoneTransitionDefinition.new(o2, o1, Time.utc(2000, 4,2,1,0,0).to_i)
    t2 = TimezoneTransitionDefinition.new(o3, o2, Time.utc(2000,10,2,1,0,0).to_i)
    t3 = TimezoneTransitionDefinition.new(o2, o3, Time.utc(2001, 3,2,1,0,0).to_i)
    t4 = TimezoneTransitionDefinition.new(o4, o2, Time.utc(2001, 4,2,1,0,0).to_i)
    t5 = TimezoneTransitionDefinition.new(o3, o4, Time.utc(2001,10,2,1,0,0).to_i)
    t6 = TimezoneTransitionDefinition.new(o3, o3, Time.utc(2002,10,2,1,0,0).to_i)
    t7 = TimezoneTransitionDefinition.new(o2, o3, Time.utc(2003, 2,2,1,0,0).to_i)
    
    
    assert_equal([TimezonePeriod.new(nil, t1)], dti.periods_for_local(DateTime.new(1960, 1, 1, 1, 0, 0)))
    assert_equal([TimezonePeriod.new(nil, t1)], dti.periods_for_local(DateTime.new(1999,12, 1, 0, 0, 0)))
    assert_equal([TimezonePeriod.new(nil, t1)], dti.periods_for_local(Time.utc(    2000, 1, 1,10, 0, 0)))
    assert_equal([TimezonePeriod.new(nil, t1)], dti.periods_for_local(Time.utc(    2000, 4, 1,20, 1,39)))
    assert_equal([],                            dti.periods_for_local(Time.utc(    2000, 4, 1,20, 1,40)))
    assert_equal([],                            dti.periods_for_local(Time.utc(    2000, 4, 1,20,59,59)))
    assert_equal([TimezonePeriod.new(t1,  t2)], dti.periods_for_local(Time.utc(    2000, 4, 1,21, 0, 0)))
    assert_equal([TimezonePeriod.new(t1,  t2)], dti.periods_for_local(DateTime.new(2000,10, 1,19,59,59)))
    assert_equal([TimezonePeriod.new(t1,  t2),
                  TimezonePeriod.new(t2,  t3)], dti.periods_for_local(Time.utc(    2000,10, 1,20, 0, 0).to_i))   
    assert_equal([TimezonePeriod.new(t1,  t2),
                  TimezonePeriod.new(t2,  t3)], dti.periods_for_local(DateTime.new(2000,10, 1,20,59,59)))
    assert_equal([TimezonePeriod.new(t2,  t3)], dti.periods_for_local(Time.utc(    2000,10, 1,21, 0, 0)))
    assert_equal([TimezonePeriod.new(t2,  t3)], dti.periods_for_local(Time.utc(    2001, 3, 1,19,59,59)))
    assert_equal([],                            dti.periods_for_local(Time.utc(    2001, 3, 1,20, 0, 0)))
    assert_equal([],                            dti.periods_for_local(DateTime.new(2001, 3, 1,20, 30, 0)))
    assert_equal([],                            dti.periods_for_local(Time.utc(    2001, 3, 1,20,59,59).to_i))
    assert_equal([TimezonePeriod.new(t3,  t4)], dti.periods_for_local(Time.utc(    2001, 3, 1,21, 0, 0)))
    assert_equal([TimezonePeriod.new(t3,  t4)], dti.periods_for_local(Time.utc(    2001, 4, 1,19,59,59)))
    assert_equal([TimezonePeriod.new(t3,  t4),
                  TimezonePeriod.new(t4,  t5)], dti.periods_for_local(DateTime.new(2001, 4, 1,20, 0, 0)))
    assert_equal([TimezonePeriod.new(t3,  t4),
                  TimezonePeriod.new(t4,  t5)], dti.periods_for_local(Time.utc(    2001, 4, 1,20,59,59)))                  
    assert_equal([TimezonePeriod.new(t4,  t5)], dti.periods_for_local(Time.utc(    2001, 4, 1,21, 0, 0)))
    assert_equal([TimezonePeriod.new(t4,  t5)], dti.periods_for_local(Time.utc(    2001,10, 1,19,59,59)))
    assert_equal([TimezonePeriod.new(t5,  t6)], dti.periods_for_local(Time.utc(    2001,10, 1,20, 0, 0)))
    assert_equal([TimezonePeriod.new(t5,  t6)], dti.periods_for_local(Time.utc(    2002, 2, 1,20, 0, 0)))
    assert_equal([TimezonePeriod.new(t5,  t6)], dti.periods_for_local(Time.utc(    2002,10, 1,19,59,59)))
    assert_equal([TimezonePeriod.new(t6,  t7)], dti.periods_for_local(Time.utc(    2002,10, 1,20, 0, 0)))
    assert_equal([TimezonePeriod.new(t6,  t7)], dti.periods_for_local(Time.utc(    2003, 2, 1,19,59,59)))
    assert_equal([],                            dti.periods_for_local(Time.utc(    2003, 2, 1,20, 0, 0)))
    assert_equal([],                            dti.periods_for_local(Time.utc(    2003, 2, 1,20,59,59)))
    assert_equal([TimezonePeriod.new(t7, nil)], dti.periods_for_local(Time.utc(    2003, 2, 1,21, 0, 0)))
    assert_equal([TimezonePeriod.new(t7, nil)], dti.periods_for_local(Time.utc(    2004, 2, 1,20, 0, 0)))
    assert_equal([TimezonePeriod.new(t7, nil)], dti.periods_for_local(DateTime.new(2040, 2, 1,20, 0, 0)))
  end
      
  def test_periods_for_local_warsaw
    dti = TransitionDataTimezoneInfo.new('Test/Europe/Warsaw')
    dti.offset :o1, 5040,    0, :LMT
    dti.offset :o2, 5040,    0, :WMT
    dti.offset :o3, 3600,    0, :CET
    dti.offset :o4, 3600, 3600, :CEST
    
    dti.transition 1879, 12, :o2, 288925853, 120  # 1879,12,31,22,36,0
    dti.transition 1915,  8, :o3, 290485733, 120  # 1915, 8, 4,22,36,0
    dti.transition 1916,  4, :o4,  29051813,  12  # 1916, 4,30,22, 0,0
    
    o1 = TimezoneOffset.new(5040,    0, :LMT)
    o2 = TimezoneOffset.new(5040,    0, :WMT)
    o3 = TimezoneOffset.new(3600,    0, :CET)
    o4 = TimezoneOffset.new(3600, 3600, :CEST)
    
    t1 = TimezoneTransitionDefinition.new(o2, o1, 288925853, 120)
    t2 = TimezoneTransitionDefinition.new(o3, o2, 290485733, 120)
    t3 = TimezoneTransitionDefinition.new(o4, o3,  29051813,  12)
    
    assert_equal([TimezonePeriod.new(t1, t2),
                  TimezonePeriod.new(t2, t3)], dti.periods_for_local(DateTime.new(1915,8,4,23,40,0)))      
  end
    
  def test_periods_for_local_boundary
    dti = TransitionDataTimezoneInfo.new('Test/Zone')
    dti.offset :o1, -3600, 0, :TESTD
    dti.offset :o2, -3600, 0, :TESTS
    
    dti.transition 2000, 7, :o2, Time.utc(2000,7,1,0,0,0).to_i
    
    o1 = TimezoneOffset.new(-3600, 0, :TESTD)
    o2 = TimezoneOffset.new(-3600, 0, :TESTS)
    
    t1 = TimezoneTransitionDefinition.new(o2, o1, Time.utc(2000,7,1,0,0,0).to_i)
                
    # 2000-07-01 00:00:00 UTC is 2000-06-30 23:00:00 UTC-1
    # hence to find periods for local times between 2000-06-30 23:00:00
    # and 2000-07-01 00:00:00 a search has to be carried out in the next half
    # year to the one containing the date we are looking for
    
    assert_equal([TimezonePeriod.new(nil, t1)], dti.periods_for_local(Time.utc(2000,6,30,22,59,59)))
    assert_equal([TimezonePeriod.new(t1, nil)], dti.periods_for_local(Time.utc(2000,6,30,23, 0, 0)))
    assert_equal([TimezonePeriod.new(t1, nil)], dti.periods_for_local(Time.utc(2000,7, 1, 0, 0, 0)))    
  end
    
  def test_periods_for_local_no_transitions
    dti = TransitionDataTimezoneInfo.new('Test/Zone')
    dti.offset :o1, -17900, 0, :TESTLMT
    dti.offset :o2, -18000, 0, :TEST
    
    o1 = TimezoneOffset.new(-17900, 0, :TESTLMT)
    
    assert_equal([TimezonePeriod.new(nil, nil, o1)], dti.periods_for_local(DateTime.new(2005,1,1,0,0,0)))
    assert_equal([TimezonePeriod.new(nil, nil, o1)], dti.periods_for_local(Time.utc(2005,1,1,0,0,0)))
    assert_equal([TimezonePeriod.new(nil, nil, o1)], dti.periods_for_local(Time.utc(2005,1,1,0,0,0).to_i))       
  end
    
  def test_periods_for_local_no_offsets
    dti = TransitionDataTimezoneInfo.new('Test/Zone')
    
    assert_raises(NoOffsetsDefined) { dti.periods_for_local(DateTime.new(2005,1,1,0,0,0)) }
    assert_raises(NoOffsetsDefined) { dti.periods_for_local(Time.utc(2005,1,1,0,0,0)) }
    assert_raises(NoOffsetsDefined) { dti.periods_for_local(Time.utc(2005,1,1,0,0,0).to_i) }
  end
  
  def test_transitions_up_to
    dti = TransitionDataTimezoneInfo.new('Test/Zone')
    dti.offset :o1, -17900,    0, :TESTLMT
    dti.offset :o2, -18000, 3600, :TESTD
    dti.offset :o3, -18000,    0, :TESTS
    dti.offset :o4, -21600, 3600, :TESTD
    
    dti.transition 2010,  4, :o2, Time.utc(2010, 4,1,1,0,0).to_i
    dti.transition 2010, 10, :o3, Time.utc(2010,10,1,1,0,0).to_i
    dti.transition 2011,  3, :o2, 58934917, 24                    # (2011, 3,1,1,0,0)
    dti.transition 2011,  4, :o4, Time.utc(2011, 4,1,1,0,0).to_i, 58935661, 24
    dti.transition 2011, 10, :o3, Time.utc(2011,10,1,1,0,0).to_i
    
    o1 = TimezoneOffset.new(-17900, 0,    :TESTLMT)
    o2 = TimezoneOffset.new(-18000, 3600, :TESTD)
    o3 = TimezoneOffset.new(-18000, 0,    :TESTS)
    o4 = TimezoneOffset.new(-21600, 3600, :TESTD)
    
    t1 = TimezoneTransitionDefinition.new(o2, o1, Time.utc(2010, 4,1,1,0,0).to_i)
    t2 = TimezoneTransitionDefinition.new(o3, o2, Time.utc(2010,10,1,1,0,0).to_i)
    t3 = TimezoneTransitionDefinition.new(o2, o3, Time.utc(2011, 3,1,1,0,0).to_i)
    t4 = TimezoneTransitionDefinition.new(o4, o2, Time.utc(2011, 4,1,1,0,0).to_i)
    t5 = TimezoneTransitionDefinition.new(o3, o4, Time.utc(2011,10,1,1,0,0).to_i)
    
    assert_equal([], dti.transitions_up_to(Time.utc(2010,4,1,1,0,0)))
    assert_equal([], dti.transitions_up_to(Time.utc(2010,4,1,1,0,0), Time.utc(2000,1,1,0,0,0)))
    assert_equal([t1], dti.transitions_up_to(Time.utc(2010,4,1,1,0,1)))
    assert_equal([t1], dti.transitions_up_to(Time.utc(2010,4,1,1,0,1), Time.utc(2000,1,1,0,0,0)))
    assert_equal([t2,t3,t4], dti.transitions_up_to(Time.utc(2011,4,1,1,0,1), Time.utc(2010,10,1,1,0,0)))
    assert_equal([t2,t3,t4], dti.transitions_up_to(Time.utc(2011,10,1,1,0,0), Time.utc(2010,4,1,1,0,1)))
    assert_equal([t3], dti.transitions_up_to(Time.utc(2011,4,1,1,0,0), Time.utc(2010,10,1,1,0,1)))
    assert_equal([], dti.transitions_up_to(Time.utc(2011,3,1,1,0,0), Time.utc(2010,10,1,1,0,1)))
    assert_equal([t1,t2,t3,t4], dti.transitions_up_to(Time.utc(2011,10,1,1,0,0)))
    assert_equal([t1,t2,t3,t4,t5], dti.transitions_up_to(Time.utc(2011,10,1,1,0,1)))
    assert_equal([t1,t2,t3,t4,t5], dti.transitions_up_to(Time.utc(2011,10,1,1,0,0,1)))
    assert_equal([t1,t2,t3,t4,t5], dti.transitions_up_to(Time.utc(2011,10,1,1,0,1), Time.utc(2010,4,1,1,0,0)))
    assert_equal([t2,t3,t4,t5], dti.transitions_up_to(Time.utc(2011,10,1,1,0,1), Time.utc(2010,4,1,1,0,1)))
    assert_equal([t2,t3,t4,t5], dti.transitions_up_to(Time.utc(2011,10,1,1,0,1), Time.utc(2010,4,1,1,0,0,1)))
    assert_equal([t5], dti.transitions_up_to(Time.utc(2015,1,1,0,0,0), Time.utc(2011,10,1,1,0,0)))
    assert_equal([], dti.transitions_up_to(Time.utc(2015,1,1,0,0,0), Time.utc(2011,10,1,1,0,1)))

    assert_equal([], dti.transitions_up_to(Time.utc(2010,4,1,1,0,0).to_i))
    assert_equal([], dti.transitions_up_to(Time.utc(2010,4,1,1,0,0).to_i, Time.utc(2000,1,1,0,0,0).to_i))
    assert_equal([t1], dti.transitions_up_to(Time.utc(2010,4,1,1,0,1).to_i))
    assert_equal([t1], dti.transitions_up_to(Time.utc(2010,4,1,1,0,1).to_i, Time.utc(2000,1,1,0,0,0).to_i))
    assert_equal([t2,t3,t4], dti.transitions_up_to(Time.utc(2011,4,1,1,0,1).to_i, Time.utc(2010,10,1,1,0,0).to_i))
    assert_equal([t2,t3,t4], dti.transitions_up_to(Time.utc(2011,10,1,1,0,0).to_i, Time.utc(2010,4,1,1,0,1).to_i))
    assert_equal([t3], dti.transitions_up_to(Time.utc(2011,4,1,1,0,0).to_i, Time.utc(2010,10,1,1,0,1).to_i))
    assert_equal([], dti.transitions_up_to(Time.utc(2011,3,1,1,0,0).to_i, Time.utc(2010,10,1,1,0,1).to_i))
    assert_equal([t1,t2,t3,t4], dti.transitions_up_to(Time.utc(2011,10,1,1,0,0).to_i))
    assert_equal([t1,t2,t3,t4,t5], dti.transitions_up_to(Time.utc(2011,10,1,1,0,1).to_i))
    assert_equal([t1,t2,t3,t4,t5], dti.transitions_up_to(Time.utc(2011,10,1,1,0,1).to_i, Time.utc(2010,4,1,1,0,0).to_i))
    assert_equal([t2,t3,t4,t5], dti.transitions_up_to(Time.utc(2011,10,1,1,0,1).to_i, Time.utc(2010,4,1,1,0,1).to_i))
    assert_equal([t5], dti.transitions_up_to(Time.utc(2015,1,1,0,0,0).to_i, Time.utc(2011,10,1,1,0,0).to_i))
    assert_equal([], dti.transitions_up_to(Time.utc(2015,1,1,0,0,0).to_i, Time.utc(2011,10,1,1,0,1).to_i))
    
    assert_equal([], dti.transitions_up_to(DateTime.new(2010,4,1,1,0,0)))
    assert_equal([], dti.transitions_up_to(DateTime.new(2010,4,1,1,0,0), DateTime.new(2000,1,1,0,0,0)))
    assert_equal([t1], dti.transitions_up_to(DateTime.new(2010,4,1,1,0,1)))
    assert_equal([t1], dti.transitions_up_to(DateTime.new(2010,4,1,1,0,1), DateTime.new(2000,1,1,0,0,0)))
    assert_equal([t2,t3,t4], dti.transitions_up_to(DateTime.new(2011,4,1,1,0,1), DateTime.new(2010,10,1,1,0,0)))
    assert_equal([t2,t3,t4], dti.transitions_up_to(DateTime.new(2011,10,1,1,0,0), DateTime.new(2010,4,1,1,0,1)))
    assert_equal([t3], dti.transitions_up_to(DateTime.new(2011,4,1,1,0,0), DateTime.new(2010,10,1,1,0,1)))
    assert_equal([], dti.transitions_up_to(DateTime.new(2011,3,1,1,0,0), DateTime.new(2010,10,1,1,0,1)))
    assert_equal([t1,t2,t3,t4], dti.transitions_up_to(DateTime.new(2011,10,1,1,0,0)))
    assert_equal([t1,t2,t3,t4,t5], dti.transitions_up_to(DateTime.new(2011,10,1,1,0,1)))
    assert_equal([t1,t2,t3,t4,t5], dti.transitions_up_to(DateTime.new(2011,10,1,1,0,Rational(DATETIME_RESOLUTION,1000000))))
    assert_equal([t1,t2,t3,t4,t5], dti.transitions_up_to(DateTime.new(2011,10,1,1,0,1), DateTime.new(2010,4,1,1,0,0)))
    assert_equal([t2,t3,t4,t5], dti.transitions_up_to(DateTime.new(2011,10,1,1,0,1), DateTime.new(2010,4,1,1,0,1)))
    assert_equal([t2,t3,t4,t5], dti.transitions_up_to(DateTime.new(2011,10,1,1,0,1), DateTime.new(2010,4,1,1,0,Rational(DATETIME_RESOLUTION,1000000))))
    assert_equal([t5], dti.transitions_up_to(DateTime.new(2015,1,1,0,0,0), DateTime.new(2011,10,1,1,0,0)))
    assert_equal([], dti.transitions_up_to(DateTime.new(2015,1,1,0,0,0), DateTime.new(2011,10,1,1,0,1)))
  end
  
  def test_transitions_up_to_no_transitions
    dti = TransitionDataTimezoneInfo.new('Test/Zone')
    dti.offset :o1, -17900, 0, :TESTLMT
        
    assert_equal([], dti.transitions_up_to(Time.utc(2015,1,1,0,0,0)))
    assert_equal([], dti.transitions_up_to(Time.utc(2015,1,1,0,0,0).to_i))
    assert_equal([], dti.transitions_up_to(DateTime.new(2015,1,1,0,0,0)))
  end
  
  def test_transitions_up_to_utc_to_not_greater_than_utc_from
    dti = TransitionDataTimezoneInfo.new('Test/Zone')
    dti.offset :o1, -17900, 0, :TESTLMT
    
    assert_raises(ArgumentError) do
      dti.transitions_up_to(Time.utc(2012,8,1,0,0,0), Time.utc(2013,8,1,0,0,0))
    end
    
    assert_raises(ArgumentError) do
      dti.transitions_up_to(Time.utc(2012,8,1,0,0,0).to_i, Time.utc(2012,8,1,0,0,0).to_i)
    end
    
    assert_raises(ArgumentError) do
      dti.transitions_up_to(DateTime.new(2012,8,1,0,0,0), DateTime.new(2012,8,1,0,0,0))
    end
  end
  
  def test_datetime_and_timestamp_use
    dti = TransitionDataTimezoneInfo.new('Test/Zone')
    dti.offset :o1, 0,    0, :TESTS
    dti.offset :o2, 0, 3600, :TESTD    
    
    dti.transition 1901, 12, :o2, -2147483649, 69573092117, 28800
    dti.transition 1969, 12, :o1, -1, 210866759999, 86400
    dti.transition 2001,  9, :o2, 1000000000, 529666909, 216
    dti.transition 2038,  1, :o1, 2147483648, 3328347557, 1350
    
    if RubyCoreSupport.time_supports_negative && RubyCoreSupport.time_supports_64bit
      assert(dti.period_for_utc(DateTime.new(1901,12,13,20,45,51)).start_transition.at.eql?(TimeOrDateTime.new(-2147483649)))
    else
      assert(dti.period_for_utc(DateTime.new(1901,12,13,20,45,51)).start_transition.at.eql?(TimeOrDateTime.new(DateTime.new(1901,12,13,20,45,51))))
    end
    
    if RubyCoreSupport.time_supports_negative          
      assert(dti.period_for_utc(DateTime.new(1969,12,31,23,59,59)).start_transition.at.eql?(TimeOrDateTime.new(-1)))
    else
      assert(dti.period_for_utc(DateTime.new(1969,12,31,23,59,59)).start_transition.at.eql?(TimeOrDateTime.new(DateTime.new(1969,12,31,23,59,59))))
    end
    
    assert(dti.period_for_utc(DateTime.new(2001,9,9,2,46,40)).start_transition.at.eql?(TimeOrDateTime.new(1000000000)))
        
    if RubyCoreSupport.time_supports_64bit
      assert(dti.period_for_utc(DateTime.new(2038,1,19,3,14,8)).start_transition.at.eql?(TimeOrDateTime.new(2147483648)))
    else
      assert(dti.period_for_utc(DateTime.new(2038,1,19,3,14,8)).start_transition.at.eql?(TimeOrDateTime.new(DateTime.new(2038,1,19,3,14,8))))
    end
  end
end
