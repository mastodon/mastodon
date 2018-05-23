require File.join(File.expand_path(File.dirname(__FILE__)), 'test_utils')

include TZInfo

class TCInfoTimezone < Minitest::Test
  
  class TestInfoTimezone < InfoTimezone
    attr_reader :setup_info
    
    protected
      def setup(info)
        super(info)
        @setup_info = info
      end     
  end
  
  def test_identifier
    tz = InfoTimezone.new(TimezoneInfo.new('Test/Identifier'))
    assert_equal('Test/Identifier', tz.identifier)
  end
  
  def test_info
    i = TimezoneInfo.new('Test/Identifier')
    tz = InfoTimezone.new(i)
    assert_same(i, tz.send(:info))
  end
  
  def test_setup
    i = TimezoneInfo.new('Test/Identifier')
    tz = TestInfoTimezone.new(i)
    assert_same(i, tz.setup_info)
  end
end

