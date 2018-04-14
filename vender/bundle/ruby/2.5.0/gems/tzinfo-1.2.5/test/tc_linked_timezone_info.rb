require File.join(File.expand_path(File.dirname(__FILE__)), 'test_utils')

include TZInfo

class TCLinkedTimezoneInfo < Minitest::Test
  
  def test_identifier
    lti = LinkedTimezoneInfo.new('Test/Zone', 'Test/Linked')
    assert_equal('Test/Zone', lti.identifier)
  end
  
  def test_link_to_identifier
    lti = LinkedTimezoneInfo.new('Test/Zone', 'Test/Linked')
    assert_equal('Test/Linked', lti.link_to_identifier)
  end
  
  def test_construct_timezone
    lti = LinkedTimezoneInfo.new('Test/Zone', 'Europe/London')
    tz = lti.create_timezone
    assert_kind_of(LinkedTimezone, tz)
    assert_equal('Test/Zone', tz.identifier)
  end
end
