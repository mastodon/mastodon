require File.join(File.expand_path(File.dirname(__FILE__)), 'test_utils')

include TZInfo

class TCTimezoneIndexDefinition < Minitest::Test
  
  module TimezonesTest1
    include TimezoneIndexDefinition
    
    timezone 'Test/One'
    timezone 'Test/Two'
    linked_timezone 'Test/Three'
    timezone 'Another/Zone'
    linked_timezone 'And/Yet/Another'
  end
  
  module TimezonesTest2
    include TimezoneIndexDefinition
    
    timezone 'Test/A/One'
    timezone 'Test/A/Two'
    timezone 'Test/A/Three'
  end
  
  module TimezonesTest3
    include TimezoneIndexDefinition
    
    linked_timezone 'Test/B/One'
    linked_timezone 'Test/B/Two'
    linked_timezone 'Test/B/Three'
  end
  
  module TimezonesTest4
    include TimezoneIndexDefinition
    
  end
  
  def test_timezones
    assert_equal(['Test/One', 'Test/Two', 'Test/Three', 'Another/Zone', 'And/Yet/Another'], TimezonesTest1.timezones)            
    assert_equal(['Test/A/One', 'Test/A/Two', 'Test/A/Three'], TimezonesTest2.timezones)
    assert_equal(['Test/B/One', 'Test/B/Two', 'Test/B/Three'], TimezonesTest3.timezones)
    assert_equal([], TimezonesTest4.timezones)
      
    assert_equal(true, TimezonesTest1.timezones.frozen?)
    assert_equal(true, TimezonesTest2.timezones.frozen?)
    assert_equal(true, TimezonesTest3.timezones.frozen?)
    assert_equal(true, TimezonesTest4.timezones.frozen?)
  end   
  
  def test_data_timezones
    assert_equal(['Test/One', 'Test/Two', 'Another/Zone'], TimezonesTest1.data_timezones)
    assert_equal(['Test/A/One', 'Test/A/Two', 'Test/A/Three'], TimezonesTest2.data_timezones)
    assert_equal([], TimezonesTest3.data_timezones)
    assert_equal([], TimezonesTest4.data_timezones)
    
    assert_equal(true, TimezonesTest1.data_timezones.frozen?)
    assert_equal(true, TimezonesTest2.data_timezones.frozen?)
    assert_equal(true, TimezonesTest3.data_timezones.frozen?)
    assert_equal(true, TimezonesTest4.data_timezones.frozen?)
  end
  
  def test_linked_timezones
    assert_equal(['Test/Three', 'And/Yet/Another'], TimezonesTest1.linked_timezones)
    assert_equal([], TimezonesTest2.linked_timezones)
    assert_equal(['Test/B/One', 'Test/B/Two', 'Test/B/Three'], TimezonesTest3.linked_timezones)
    assert_equal([], TimezonesTest4.linked_timezones)
    
    assert_equal(true, TimezonesTest1.linked_timezones.frozen?)
    assert_equal(true, TimezonesTest2.linked_timezones.frozen?)
    assert_equal(true, TimezonesTest3.linked_timezones.frozen?)
    assert_equal(true, TimezonesTest4.linked_timezones.frozen?)
  end  
end
