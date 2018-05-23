require File.join(File.expand_path(File.dirname(__FILE__)), 'test_utils')

include TZInfo

class TCDataTimezoneInfo < Minitest::Test
  
  def test_identifier
    ti = DataTimezoneInfo.new('Test/Zone')
    assert_equal('Test/Zone', ti.identifier)
  end
  
  def test_construct_timezone
    ti = DataTimezoneInfo.new('Test/Zone')
    tz = ti.create_timezone
    assert_kind_of(DataTimezone, tz)
    assert_equal('Test/Zone', tz.identifier)
  end
end
