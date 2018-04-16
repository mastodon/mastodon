require File.join(File.expand_path(File.dirname(__FILE__)), 'test_utils')

include TZInfo

class TCTimezoneUTC < Minitest::Test
  def test_2004        
    tz = Timezone.get('UTC')
    
    assert_equal(DateTime.new(2004,1,1,0,0,0), tz.utc_to_local(DateTime.new(2004,1,1,0,0,0)))
    assert_equal(DateTime.new(2004,12,31,23,59,59), tz.utc_to_local(DateTime.new(2004,12,31,23,59,59)))
    
    assert_equal(DateTime.new(2004,1,1,0,0,0), tz.local_to_utc(DateTime.new(2004,1,1,0,0,0)))
    assert_equal(DateTime.new(2004,12,31,23,59,59), tz.local_to_utc(DateTime.new(2004,12,31,23,59,59)))
        
    assert_equal(:UTC, tz.period_for_utc(DateTime.new(2004,1,1,0,0,0)).zone_identifier)    
    assert_equal(:UTC, tz.period_for_utc(DateTime.new(2004,12,31,23,59,59)).zone_identifier)
    
    assert_equal(:UTC, tz.period_for_local(DateTime.new(2004,1,1,0,0,0)).zone_identifier)    
    assert_equal(:UTC, tz.period_for_local(DateTime.new(2004,12,31,23,59,59)).zone_identifier)
        
    assert_equal(0, tz.period_for_utc(DateTime.new(2004,1,1,0,0,0)).utc_total_offset)    
    assert_equal(0, tz.period_for_utc(DateTime.new(2004,12,31,23,59,59)).utc_total_offset)
    
    assert_equal(0, tz.period_for_local(DateTime.new(2004,1,1,0,0,0)).utc_total_offset)    
    assert_equal(0, tz.period_for_local(DateTime.new(2004,12,31,23,59,59)).utc_total_offset)    
  end    
end
