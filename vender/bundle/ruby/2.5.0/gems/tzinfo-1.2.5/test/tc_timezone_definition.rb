require File.join(File.expand_path(File.dirname(__FILE__)), 'test_utils')

include TZInfo

class TCTimezoneDefinition < Minitest::Test

  module DataTest
    include TimezoneDefinition
    
    timezone 'Test/Data/Zone' do |tz|
      tz.offset :o0, -75, 0, :LMT
      tz.offset :o1,   0, 0, :GMT
      
      tz.transition 1847, 12, :o1, 2760187969, 1152 
    end
  end
  
  module LinkedTest
    include TimezoneDefinition
    
    linked_timezone 'Test/Linked/Zone', 'Test/Linked_To/Zone'
  end
  
  module DoubleDataTest
    include TimezoneDefinition
    
    timezone 'Test/Data/Zone1' do |tz|
      tz.offset :o0, -75, 0, :LMT
      tz.offset :o1,   0, 0, :GMT
      
      tz.transition 1847, 12, :o1, 2760187969, 1152 
    end
    
    timezone 'Test/Data/Zone2' do |tz|
      tz.offset :o0, 75, 0, :LMT
      tz.offset :o1,  0, 0, :GMT
      
      tz.transition 1847, 12, :o1, 2760187969, 1152 
    end
  end
  
  module DoubleLinkedTest
    include TimezoneDefinition
    
    linked_timezone 'Test/Linked/Zone1', 'Test/Linked_To/Zone1'
    linked_timezone 'Test/Linked/Zone2', 'Test/Linked_To/Zone2'
  end
  
  module DataLinkedTest
    include TimezoneDefinition
    
    timezone 'Test/Data/Zone1' do |tz|
      tz.offset :o0, -75, 0, :LMT
      tz.offset :o1,   0, 0, :GMT
      
      tz.transition 1847, 12, :o1, 2760187969, 1152 
    end 
    
    linked_timezone 'Test/Linked/Zone2', 'Test/Linked_To/Zone2'
  end
  
  module LinkedDataTest
    include TimezoneDefinition
    
    linked_timezone 'Test/Linked/Zone1', 'Test/Linked_To/Zone1'
    
    timezone 'Test/Data/Zone2' do |tz|
      tz.offset :o0, -75, 0, :LMT
      tz.offset :o1,   0, 0, :GMT
      
      tz.transition 1847, 12, :o1, 2760187969, 1152 
    end    
  end
    
  def test_data
    assert_kind_of(TransitionDataTimezoneInfo, DataTest.get)
    assert_equal('Test/Data/Zone', DataTest.get.identifier)
    assert_equal(:LMT, DataTest.get.period_for_utc(DateTime.new(1847,12,1,0,1,14)).abbreviation)
    assert_equal(:GMT, DataTest.get.period_for_utc(DateTime.new(1847,12,1,0,1,15)).abbreviation)
  end
  
  def test_linked
    assert_kind_of(LinkedTimezoneInfo, LinkedTest.get)
    assert_equal('Test/Linked/Zone', LinkedTest.get.identifier)
    assert_equal('Test/Linked_To/Zone', LinkedTest.get.link_to_identifier)    
  end
  
  def test_double_data
    assert_kind_of(TransitionDataTimezoneInfo, DoubleDataTest.get)
    assert_equal('Test/Data/Zone2', DoubleDataTest.get.identifier)
    assert_equal(:LMT, DoubleDataTest.get.period_for_utc(DateTime.new(1847,12,1,0,1,14)).abbreviation)
    assert_equal(:GMT, DoubleDataTest.get.period_for_utc(DateTime.new(1847,12,1,0,1,15)).abbreviation)
  end
  
  def test_double_linked
    assert_kind_of(LinkedTimezoneInfo, DoubleLinkedTest.get)
    assert_equal('Test/Linked/Zone2', DoubleLinkedTest.get.identifier)
    assert_equal('Test/Linked_To/Zone2', DoubleLinkedTest.get.link_to_identifier)    
  end
  
  def test_data_linked
    assert_kind_of(LinkedTimezoneInfo, DataLinkedTest.get)
    assert_equal('Test/Linked/Zone2', DataLinkedTest.get.identifier)
    assert_equal('Test/Linked_To/Zone2', DataLinkedTest.get.link_to_identifier)    
  end
  
  def test_linked_data
    assert_kind_of(TransitionDataTimezoneInfo, LinkedDataTest.get)
    assert_equal('Test/Data/Zone2', LinkedDataTest.get.identifier)
    assert_equal(:LMT, LinkedDataTest.get.period_for_utc(DateTime.new(1847,12,1,0,1,14)).abbreviation)
    assert_equal(:GMT, LinkedDataTest.get.period_for_utc(DateTime.new(1847,12,1,0,1,15)).abbreviation)
  end  
end
