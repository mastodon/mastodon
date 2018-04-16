require File.join(File.expand_path(File.dirname(__FILE__)), 'test_utils')

include TZInfo

class TCTimezoneMelbourne < Minitest::Test
  def test_2004
    #Australia/Melbourne  Sat Mar 27 15:59:59 2004 UTC = Sun Mar 28 02:59:59 2004 AEDT isdst=1 gmtoff=39600
    #Australia/Melbourne  Sat Mar 27 16:00:00 2004 UTC = Sun Mar 28 02:00:00 2004 AEST isdst=0 gmtoff=36000
    #Australia/Melbourne  Sat Oct 30 15:59:59 2004 UTC = Sun Oct 31 01:59:59 2004 AEST isdst=0 gmtoff=36000
    #Australia/Melbourne  Sat Oct 30 16:00:00 2004 UTC = Sun Oct 31 03:00:00 2004 AEDT isdst=1 gmtoff=39600
    
    tz = Timezone.get('Australia/Melbourne')
    assert_equal(DateTime.new(2004,3,28,2,59,59), tz.utc_to_local(DateTime.new(2004,3,27,15,59,59)))
    assert_equal(DateTime.new(2004,3,28,2,0,0), tz.utc_to_local(DateTime.new(2004,3,27,16,0,0)))    
    assert_equal(DateTime.new(2004,10,31,1,59,59), tz.utc_to_local(DateTime.new(2004,10,30,15,59,59)))
    assert_equal(DateTime.new(2004,10,31,3,0,0), tz.utc_to_local(DateTime.new(2004,10,30,16,0,0)))
    
    assert_equal(DateTime.new(2004,3,27,15,59,59), tz.local_to_utc(DateTime.new(2004,3,28,2,59,59), true))
    assert_equal(DateTime.new(2004,3,27,16,59,59), tz.local_to_utc(DateTime.new(2004,3,28,2,59,59), false))
    assert_equal(DateTime.new(2004,3,27,15,0,0), tz.local_to_utc(DateTime.new(2004,3,28,2,0,0), true))
    assert_equal(DateTime.new(2004,3,27,16,0,0), tz.local_to_utc(DateTime.new(2004,3,28,2,0,0), false))   
    assert_equal(DateTime.new(2004,10,30,15,59,59), tz.local_to_utc(DateTime.new(2004,10,31,1,59,59)))
    assert_equal(DateTime.new(2004,10,30,16,0,0), tz.local_to_utc(DateTime.new(2004,10,31,3,0,0)))
    
    assert_raises(PeriodNotFound) { tz.local_to_utc(DateTime.new(2004,10,31,2,0,0)) }
    assert_raises(AmbiguousTime) { tz.local_to_utc(DateTime.new(2004,3,28,2,0,0)) }
    
    assert_equal(:AEDT, tz.period_for_utc(DateTime.new(2004,3,27,15,59,59)).zone_identifier)
    assert_equal(:AEST, tz.period_for_utc(DateTime.new(2004,3,27,16,0,0)).zone_identifier)
    assert_equal(:AEST, tz.period_for_utc(DateTime.new(2004,10,30,15,59,59)).zone_identifier)
    assert_equal(:AEDT, tz.period_for_utc(DateTime.new(2004,10,30,16,0,0)).zone_identifier)
    
    assert_equal(:AEDT, tz.period_for_local(DateTime.new(2004,3,28,2,59,59), true).zone_identifier)
    assert_equal(:AEST, tz.period_for_local(DateTime.new(2004,3,28,2,59,59), false).zone_identifier)
    assert_equal(:AEDT, tz.period_for_local(DateTime.new(2004,3,28,2,0,0), true).zone_identifier)
    assert_equal(:AEST, tz.period_for_local(DateTime.new(2004,3,28,2,0,0), false).zone_identifier)
    assert_equal(:AEST, tz.period_for_local(DateTime.new(2004,10,31,1,59,59)).zone_identifier)
    assert_equal(:AEDT, tz.period_for_local(DateTime.new(2004,10,31,3,0,0)).zone_identifier)
    
    assert_equal(39600, tz.period_for_utc(DateTime.new(2004,3,27,15,59,59)).utc_total_offset)
    assert_equal(36000, tz.period_for_utc(DateTime.new(2004,3,27,16,0,0)).utc_total_offset)
    assert_equal(36000, tz.period_for_utc(DateTime.new(2004,10,30,15,59,59)).utc_total_offset)
    assert_equal(39600, tz.period_for_utc(DateTime.new(2004,10,30,16,0,0)).utc_total_offset)
    
    assert_equal(39600, tz.period_for_local(DateTime.new(2004,3,28,2,59,59), true).utc_total_offset)
    assert_equal(36000, tz.period_for_local(DateTime.new(2004,3,28,2,59,59), false).utc_total_offset)
    assert_equal(39600, tz.period_for_local(DateTime.new(2004,3,28,2,0,0), true).utc_total_offset)
    assert_equal(36000, tz.period_for_local(DateTime.new(2004,3,28,2,0,0), false).utc_total_offset)
    assert_equal(36000, tz.period_for_local(DateTime.new(2004,10,31,1,59,59)).utc_total_offset)
    assert_equal(39600, tz.period_for_local(DateTime.new(2004,10,31,3,0,0)).utc_total_offset)
    
    transitions = tz.transitions_up_to(DateTime.new(2005,1,1,0,0,0), DateTime.new(2004,1,1,0,0,0))
    assert_equal(2, transitions.length)
    assert_equal(TimeOrDateTime.new(DateTime.new(2004,3,27,16,0,0)), transitions[0].at)
    assert_equal(TimezoneOffset.new(36000, 3600, :AEDT), transitions[0].previous_offset)
    assert_equal(TimezoneOffset.new(36000, 0, :AEST), transitions[0].offset)
    assert_equal(TimeOrDateTime.new(DateTime.new(2004,10,30,16,0,0)), transitions[1].at)
    assert_equal(TimezoneOffset.new(36000, 0, :AEST), transitions[1].previous_offset)
    assert_equal(TimezoneOffset.new(36000, 3600, :AEDT), transitions[1].offset)
    
    offsets = tz.offsets_up_to(DateTime.new(2005,1,1,0,0,0), DateTime.new(2004,1,1,0,0,0))
    assert_array_same_items([TimezoneOffset.new(36000, 0, :AEST), TimezoneOffset.new(36000, 3600, :AEDT)], offsets)
  end  

  def test_1942
    # This test cannot be run when using ZoneinfoDataSource on platforms
    # that don't support Times before the epoch (i.e. Ruby < 1.9 on Windows) 
    # because it relates to the year 1942.
    
    if !DataSource.get.kind_of?(ZoneinfoDataSource) || RubyCoreSupport.time_supports_negative
      #Australia/Melbourne  Sat Mar 28 14:59:59 1942 UTC = Sun Mar 29 01:59:59 1942 AEDT isdst=1 gmtoff=39600
      #Australia/Melbourne  Sat Mar 28 15:00:00 1942 UTC = Sun Mar 29 01:00:00 1942 AEST isdst=0 gmtoff=36000
      #Australia/Melbourne  Sat Sep 26 15:59:59 1942 UTC = Sun Sep 27 01:59:59 1942 AEST isdst=0 gmtoff=36000
      #Australia/Melbourne  Sat Sep 26 16:00:00 1942 UTC = Sun Sep 27 03:00:00 1942 AEDT isdst=1 gmtoff=39600
      
      tz = Timezone.get('Australia/Melbourne')
      assert_equal(DateTime.new(1942,3,29,1,59,59), tz.utc_to_local(DateTime.new(1942,3,28,14,59,59)))
      assert_equal(DateTime.new(1942,3,29,1,0,0), tz.utc_to_local(DateTime.new(1942,3,28,15,0,0)))    
      assert_equal(DateTime.new(1942,9,27,1,59,59), tz.utc_to_local(DateTime.new(1942,9,26,15,59,59)))
      assert_equal(DateTime.new(1942,9,27,3,0,0), tz.utc_to_local(DateTime.new(1942,9,26,16,0,0)))
      
      assert_equal(DateTime.new(1942,3,28,14,59,59), tz.local_to_utc(DateTime.new(1942,3,29,1,59,59), true))
      assert_equal(DateTime.new(1942,3,28,15,59,59), tz.local_to_utc(DateTime.new(1942,3,29,1,59,59), false))
      assert_equal(DateTime.new(1942,3,28,14,0,0), tz.local_to_utc(DateTime.new(1942,3,29,1,0,0), true))
      assert_equal(DateTime.new(1942,3,28,15,0,0), tz.local_to_utc(DateTime.new(1942,3,29,1,0,0), false))   
      assert_equal(DateTime.new(1942,9,26,15,59,59), tz.local_to_utc(DateTime.new(1942,9,27,1,59,59)))
      assert_equal(DateTime.new(1942,9,26,16,0,0), tz.local_to_utc(DateTime.new(1942,9,27,3,0,0)))
      
      assert_raises(PeriodNotFound) { tz.local_to_utc(DateTime.new(1942,9,27,2,0,0)) }
      assert_raises(AmbiguousTime) { tz.local_to_utc(DateTime.new(1942,3,29,1,0,0)) }
      
      assert_equal(:AEDT, tz.period_for_utc(DateTime.new(1942,3,28,14,59,59)).zone_identifier)
      assert_equal(:AEST, tz.period_for_utc(DateTime.new(1942,3,28,15,0,0)).zone_identifier)
      assert_equal(:AEST, tz.period_for_utc(DateTime.new(1942,9,26,15,59,59)).zone_identifier)
      assert_equal(:AEDT, tz.period_for_utc(DateTime.new(1942,9,26,16,0,0)).zone_identifier)
      
      assert_equal(:AEDT, tz.period_for_local(DateTime.new(1942,3,29,1,59,59), true).zone_identifier)
      assert_equal(:AEST, tz.period_for_local(DateTime.new(1942,3,29,1,59,59), false).zone_identifier)
      assert_equal(:AEDT, tz.period_for_local(DateTime.new(1942,3,29,1,0,0), true).zone_identifier)
      assert_equal(:AEST, tz.period_for_local(DateTime.new(1942,3,29,1,0,0), false).zone_identifier)
      assert_equal(:AEST, tz.period_for_local(DateTime.new(1942,9,27,1,59,59)).zone_identifier)
      assert_equal(:AEDT, tz.period_for_local(DateTime.new(1942,9,27,3,0,0)).zone_identifier)
      
      assert_equal(39600, tz.period_for_utc(DateTime.new(1942,3,28,14,59,59)).utc_total_offset)
      assert_equal(36000, tz.period_for_utc(DateTime.new(1942,3,28,15,0,0)).utc_total_offset)
      assert_equal(36000, tz.period_for_utc(DateTime.new(1942,9,26,15,59,59)).utc_total_offset)
      assert_equal(39600, tz.period_for_utc(DateTime.new(1942,9,26,16,0,0)).utc_total_offset)
      
      assert_equal(39600, tz.period_for_local(DateTime.new(1942,3,29,1,59,59), true).utc_total_offset)
      assert_equal(36000, tz.period_for_local(DateTime.new(1942,3,29,1,59,59), false).utc_total_offset)
      assert_equal(39600, tz.period_for_local(DateTime.new(1942,3,29,1,0,0), true).utc_total_offset)
      assert_equal(36000, tz.period_for_local(DateTime.new(1942,3,29,1,0,0), false).utc_total_offset)
      assert_equal(36000, tz.period_for_local(DateTime.new(1942,9,27,1,59,59)).utc_total_offset)
      assert_equal(39600, tz.period_for_local(DateTime.new(1942,9,27,3,0,0)).utc_total_offset)
      
      transitions = tz.transitions_up_to(DateTime.new(1943,1,1,0,0,0), DateTime.new(1942,1,1,0,0,0))
      assert_equal(2, transitions.length)
      assert_equal(TimeOrDateTime.new(DateTime.new(1942,3,28,15,0,0)), transitions[0].at)
      assert_equal(TimezoneOffset.new(36000, 3600, :AEDT), transitions[0].previous_offset)
      assert_equal(TimezoneOffset.new(36000, 0, :AEST), transitions[0].offset)
      assert_equal(TimeOrDateTime.new(DateTime.new(1942,9,26,16,0,0)), transitions[1].at)
      assert_equal(TimezoneOffset.new(36000, 0, :AEST), transitions[1].previous_offset)
      assert_equal(TimezoneOffset.new(36000, 3600, :AEDT), transitions[1].offset)
      
      offsets = tz.offsets_up_to(DateTime.new(1943,1,1,0,0,0), DateTime.new(1942,1,1,0,0,0))
      assert_array_same_items([TimezoneOffset.new(36000, 0, :AEST), TimezoneOffset.new(36000, 3600, :AEDT)], offsets)
    end
  end

  def test_time_boundary
    #Australia/Melbourne  Sat Mar 25 15:00:00 1944 UTC = Sun Mar 26 01:00:00 1944 AEST isdst=0 gmtoff=36000
    #Australia/Melbourne  Sat Oct 30 15:59:59 1971 UTC = Sun Oct 31 01:59:59 1971 AEST isdst=0 gmtoff=36000
    
    tz = Timezone.get('Australia/Melbourne')    
    assert_equal(DateTime.new(1970,1,1,10,0,0), tz.utc_to_local(DateTime.new(1970,1,1,0,0,0)))
    assert_equal(DateTime.new(1970,1,1,0,0,0), tz.local_to_utc(DateTime.new(1970,1,1,10,0,0)))
    assert_equal(Time.utc(1970,1,1,10,0,0), tz.utc_to_local(Time.utc(1970,1,1,0,0,0)))
    assert_equal(Time.utc(1970,1,1,0,0,0), tz.local_to_utc(Time.utc(1970,1,1,10,0,0)))
    assert_equal(36000, tz.utc_to_local(0))
    assert_equal(0, tz.local_to_utc(36000))
  end  
end
