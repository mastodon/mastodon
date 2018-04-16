require File.join(File.expand_path(File.dirname(__FILE__)), 'test_utils')

include TZInfo

class TCTimezoneLondon < Minitest::Test
  def test_2004
    #Europe/London  Sun Mar 28 00:59:59 2004 UTC = Sun Mar 28 00:59:59 2004 GMT isdst=0 gmtoff=0
    #Europe/London  Sun Mar 28 01:00:00 2004 UTC = Sun Mar 28 02:00:00 2004 BST isdst=1 gmtoff=3600
    #Europe/London  Sun Oct 31 00:59:59 2004 UTC = Sun Oct 31 01:59:59 2004 BST isdst=1 gmtoff=3600
    #Europe/London  Sun Oct 31 01:00:00 2004 UTC = Sun Oct 31 01:00:00 2004 GMT isdst=0 gmtoff=0
    
    tz = Timezone.get('Europe/London')
    assert_equal(DateTime.new(2004,3,28,0,59,59), tz.utc_to_local(DateTime.new(2004,3,28,0,59,59)))
    assert_equal(DateTime.new(2004,3,28,2,0,0), tz.utc_to_local(DateTime.new(2004,3,28,1,0,0)))    
    assert_equal(DateTime.new(2004,10,31,1,59,59), tz.utc_to_local(DateTime.new(2004,10,31,0,59,59)))
    assert_equal(DateTime.new(2004,10,31,1,0,0), tz.utc_to_local(DateTime.new(2004,10,31,1,0,0)))
    
    assert_equal(DateTime.new(2004,3,28,0,59,59), tz.local_to_utc(DateTime.new(2004,3,28,0,59,59)))
    assert_equal(DateTime.new(2004,3,28,1,0,0), tz.local_to_utc(DateTime.new(2004,3,28,2,0,0)))
    assert_equal(DateTime.new(2004,10,31,0,59,59), tz.local_to_utc(DateTime.new(2004,10,31,1,59,59), true))
    assert_equal(DateTime.new(2004,10,31,1,59,59), tz.local_to_utc(DateTime.new(2004,10,31,1,59,59), false))
    assert_equal(DateTime.new(2004,10,31,0,0,0), tz.local_to_utc(DateTime.new(2004,10,31,1,0,0), true))
    assert_equal(DateTime.new(2004,10,31,1,0,0), tz.local_to_utc(DateTime.new(2004,10,31,1,0,0), false))
    
    assert_raises(PeriodNotFound) { tz.local_to_utc(DateTime.new(2004,3,28,1,0,0)) }
    assert_raises(AmbiguousTime) { tz.local_to_utc(DateTime.new(2004,10,31,1,0,0)) }
    
    assert_equal(:GMT, tz.period_for_utc(DateTime.new(2004,3,28,0,59,59)).zone_identifier)
    assert_equal(:BST, tz.period_for_utc(DateTime.new(2004,3,28,1,0,0)).zone_identifier)
    assert_equal(:BST, tz.period_for_utc(DateTime.new(2004,10,31,0,59,59)).zone_identifier)
    assert_equal(:GMT, tz.period_for_utc(DateTime.new(2004,10,31,1,0,0)).zone_identifier)
    
    assert_equal(:GMT, tz.period_for_local(DateTime.new(2004,3,28,0,59,59)).zone_identifier)
    assert_equal(:BST, tz.period_for_local(DateTime.new(2004,3,28,2,0,0)).zone_identifier)
    assert_equal(:BST, tz.period_for_local(DateTime.new(2004,10,31,1,59,59), true).zone_identifier)
    assert_equal(:GMT, tz.period_for_local(DateTime.new(2004,10,31,1,59,59), false).zone_identifier)
    assert_equal(:BST, tz.period_for_local(DateTime.new(2004,10,31,1,0,0), true).zone_identifier)
    assert_equal(:GMT, tz.period_for_local(DateTime.new(2004,10,31,1,0,0), false).zone_identifier)
    
    assert_equal(0, tz.period_for_utc(DateTime.new(2004,3,28,0,59,59)).utc_total_offset)
    assert_equal(3600, tz.period_for_utc(DateTime.new(2004,3,28,1,0,0)).utc_total_offset)
    assert_equal(3600, tz.period_for_utc(DateTime.new(2004,10,31,0,59,59)).utc_total_offset)
    assert_equal(0, tz.period_for_utc(DateTime.new(2004,10,31,1,0,0)).utc_total_offset)
    
    assert_equal(0, tz.period_for_local(DateTime.new(2004,3,28,0,59,59)).utc_total_offset)
    assert_equal(3600, tz.period_for_local(DateTime.new(2004,3,28,2,0,0)).utc_total_offset)
    assert_equal(3600, tz.period_for_local(DateTime.new(2004,10,31,1,59,59), true).utc_total_offset)
    assert_equal(0, tz.period_for_local(DateTime.new(2004,10,31,1,59,59), false).utc_total_offset)
    assert_equal(3600, tz.period_for_local(DateTime.new(2004,10,31,1,0,0), true).utc_total_offset)
    assert_equal(0, tz.period_for_local(DateTime.new(2004,10,31,1,0,0), false).utc_total_offset)
    
    transitions = tz.transitions_up_to(DateTime.new(2005,1,1,0,0,0), DateTime.new(2004,1,1,0,0,0))
    assert_equal(2, transitions.length)
    assert_equal(TimeOrDateTime.new(DateTime.new(2004,3,28,1,0,0)), transitions[0].at)
    assert_equal(TimezoneOffset.new(0, 0, :GMT), transitions[0].previous_offset)
    assert_equal(TimezoneOffset.new(0, 3600, :BST), transitions[0].offset)
    assert_equal(TimeOrDateTime.new(DateTime.new(2004,10,31,1,0,0)), transitions[1].at)
    assert_equal(TimezoneOffset.new(0, 3600, :BST), transitions[1].previous_offset)
    assert_equal(TimezoneOffset.new(0, 0, :GMT), transitions[1].offset)
    
    offsets = tz.offsets_up_to(DateTime.new(2005,1,1,0,0,0), DateTime.new(2004,1,1,0,0,0))
    assert_array_same_items([TimezoneOffset.new(0, 0, :GMT), TimezoneOffset.new(0, 3600, :BST)], offsets)
  end 
  
  def test_1961
    # This test cannot be run when using ZoneinfoDataSource on platforms
    # that don't support Times before the epoch (i.e. Ruby < 1.9 on Windows) 
    # because it relates to the year 1961.
    
    if !DataSource.get.kind_of?(ZoneinfoDataSource) || RubyCoreSupport.time_supports_negative
      #Europe/London  Sun Mar 26 01:59:59 1961 UTC = Sun Mar 26 01:59:59 1961 GMT isdst=0 gmtoff=0
      #Europe/London  Sun Mar 26 02:00:00 1961 UTC = Sun Mar 26 03:00:00 1961 BST isdst=1 gmtoff=3600
      #Europe/London  Sun Oct 29 01:59:59 1961 UTC = Sun Oct 29 02:59:59 1961 BST isdst=1 gmtoff=3600
      #Europe/London  Sun Oct 29 02:00:00 1961 UTC = Sun Oct 29 02:00:00 1961 GMT isdst=0 gmtoff=0
      
      tz = Timezone.get('Europe/London')
      assert_equal(DateTime.new(1961,3,26,1,59,59), tz.utc_to_local(DateTime.new(1961,3,26,1,59,59)))
      assert_equal(DateTime.new(1961,3,26,3,0,0), tz.utc_to_local(DateTime.new(1961,3,26,2,0,0)))    
      assert_equal(DateTime.new(1961,10,29,2,59,59), tz.utc_to_local(DateTime.new(1961,10,29,1,59,59)))
      assert_equal(DateTime.new(1961,10,29,2,0,0), tz.utc_to_local(DateTime.new(1961,10,29,2,0,0)))
      
      assert_equal(DateTime.new(1961,3,26,1,59,59), tz.local_to_utc(DateTime.new(1961,3,26,1,59,59)))
      assert_equal(DateTime.new(1961,3,26,2,0,0), tz.local_to_utc(DateTime.new(1961,3,26,3,0,0)))
      assert_equal(DateTime.new(1961,10,29,1,59,59), tz.local_to_utc(DateTime.new(1961,10,29,2,59,59), true))
      assert_equal(DateTime.new(1961,10,29,2,59,59), tz.local_to_utc(DateTime.new(1961,10,29,2,59,59), false))
      assert_equal(DateTime.new(1961,10,29,1,0,0), tz.local_to_utc(DateTime.new(1961,10,29,2,0,0), true))
      assert_equal(DateTime.new(1961,10,29,2,0,0), tz.local_to_utc(DateTime.new(1961,10,29,2,0,0), false))
      
      assert_raises(PeriodNotFound) { tz.local_to_utc(DateTime.new(1961,3,26,2,0,0)) }
      assert_raises(AmbiguousTime) { tz.local_to_utc(DateTime.new(1961,10,29,2,0,0)) }
      
      assert_equal(:GMT, tz.period_for_utc(DateTime.new(1961,3,26,1,59,59)).zone_identifier)
      assert_equal(:BST, tz.period_for_utc(DateTime.new(1961,3,26,2,0,0)).zone_identifier)
      assert_equal(:BST, tz.period_for_utc(DateTime.new(1961,10,29,1,59,59)).zone_identifier)
      assert_equal(:GMT, tz.period_for_utc(DateTime.new(1961,10,29,2,0,0)).zone_identifier)
      
      assert_equal(:GMT, tz.period_for_local(DateTime.new(1961,3,26,1,59,59)).zone_identifier)
      assert_equal(:BST, tz.period_for_local(DateTime.new(1961,3,26,3,0,0)).zone_identifier)
      assert_equal(:BST, tz.period_for_local(DateTime.new(1961,10,29,2,59,59), true).zone_identifier)
      assert_equal(:GMT, tz.period_for_local(DateTime.new(1961,10,29,2,59,59), false).zone_identifier)
      assert_equal(:BST, tz.period_for_local(DateTime.new(1961,10,29,2,0,0), true).zone_identifier)
      assert_equal(:GMT, tz.period_for_local(DateTime.new(1961,10,29,2,0,0), false).zone_identifier)
      
      assert_equal(0, tz.period_for_utc(DateTime.new(1961,3,26,1,59,59)).utc_total_offset)
      assert_equal(3600, tz.period_for_utc(DateTime.new(1961,3,26,2,0,0)).utc_total_offset)
      assert_equal(3600, tz.period_for_utc(DateTime.new(1961,10,29,1,59,59)).utc_total_offset)
      assert_equal(0, tz.period_for_utc(DateTime.new(1961,10,29,2,0,0)).utc_total_offset)
      
      assert_equal(0, tz.period_for_local(DateTime.new(1961,3,26,1,59,59)).utc_total_offset)
      assert_equal(3600, tz.period_for_local(DateTime.new(1961,3,26,3,0,0)).utc_total_offset)
      assert_equal(3600, tz.period_for_local(DateTime.new(1961,10,29,2,59,59), true).utc_total_offset)
      assert_equal(0, tz.period_for_local(DateTime.new(1961,10,29,2,59,59), false).utc_total_offset)
      assert_equal(3600, tz.period_for_local(DateTime.new(1961,10,29,2,0,0), true).utc_total_offset)
      assert_equal(0, tz.period_for_local(DateTime.new(1961,10,29,2,0,0), false).utc_total_offset)
      
      
      transitions = tz.transitions_up_to(DateTime.new(1962,1,1,0,0,0), DateTime.new(1961,1,1,0,0,0))
      assert_equal(2, transitions.length)
      assert_equal(TimeOrDateTime.new(DateTime.new(1961,3,26,2,0,0)), transitions[0].at)
      assert_equal(TimezoneOffset.new(0, 0, :GMT), transitions[0].previous_offset)
      assert_equal(TimezoneOffset.new(0, 3600, :BST), transitions[0].offset)
      assert_equal(TimeOrDateTime.new(DateTime.new(1961,10,29,2,0,0)), transitions[1].at)
      assert_equal(TimezoneOffset.new(0, 3600, :BST), transitions[1].previous_offset)
      assert_equal(TimezoneOffset.new(0, 0, :GMT), transitions[1].offset)
      
      offsets = tz.offsets_up_to(DateTime.new(1962,1,1,0,0,0), DateTime.new(1961,1,1,0,0,0))
      assert_array_same_items([TimezoneOffset.new(0, 0, :GMT), TimezoneOffset.new(0, 3600, :BST)], offsets)
    end
  end 
  
  def test_time_boundary
    #Europe/London  Sat Oct 26 23:00:00 1968 UTC = Sun Oct 27 00:00:00 1968 GMT isdst=0 gmtoff=3600
    #Europe/London  Sun Oct 31 01:59:59 1971 UTC = Sun Oct 31 02:59:59 1971 GMT isdst=0 gmtoff=3600
    
    tz = Timezone.get('Europe/London')
    assert_equal(DateTime.new(1970,1,1,1,0,0), tz.utc_to_local(DateTime.new(1970,1,1,0,0,0)))
    assert_equal(DateTime.new(1970,1,1,0,0,0), tz.local_to_utc(DateTime.new(1970,1,1,1,0,0)))
    assert_equal(Time.utc(1970,1,1,1,0,0), tz.utc_to_local(Time.utc(1970,1,1,0,0,0)))
    assert_equal(Time.utc(1970,1,1,0,0,0), tz.local_to_utc(Time.utc(1970,1,1,1,0,0)))
    assert_equal(3600, tz.utc_to_local(0))
    assert_equal(0, tz.local_to_utc(3600))
  end
end
