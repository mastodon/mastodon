require File.join(File.expand_path(File.dirname(__FILE__)), 'test_utils')

include TZInfo

class TCLinkedTimezone < Minitest::Test
  
  class TestTimezone < Timezone
    attr_reader :utc_period
    attr_reader :local_periods
    attr_reader :up_to_transitions
    attr_reader :utc
    attr_reader :local
    attr_reader :utc_to
    attr_reader :utc_from
    
    def self.new(identifier, no_local_periods = false)
      tz = super()
      tz.send(:setup, identifier, no_local_periods)
      tz
    end
    
    def identifier
      @identifier
    end
    
    def period_for_utc(utc)
      @utc = utc
      @utc_period
    end
    
    def periods_for_local(local)
      @local = local
      raise PeriodNotFound if @no_local_periods
      @local_periods
    end
    
    def transitions_up_to(utc_to, utc_from = nil)
      @utc_to = utc_to
      @utc_from = utc_from
      @up_to_transitions
    end
    
    def canonical_zone
      self
    end
    
    private
      def setup(identifier, no_local_periods)
        @identifier = identifier
        @no_local_periods = no_local_periods
        
        # Don't have to be real TimezonePeriod or TimezoneTransition objects
        # (nothing will use them).
        @utc_period = Object.new
        @local_periods = [Object.new, Object.new]
        @up_to_transitions = [Object.new, Object.new]
      end
  end
  
  
  def setup
    # Redefine Timezone.get to return a fake timezone.
    # Use without_warnings to suppress redefined get method warning.
    without_warnings do
      def Timezone.get(identifier)
        raise InvalidTimezoneIdentifier, 'Invalid identifier' if identifier == 'Invalid/Identifier'
       
        @timezones ||= {}
        @timezones[identifier] ||= 
          identifier == 'Test/Recursive/Linked' ? 
            LinkedTimezone.new(LinkedTimezoneInfo.new(identifier, 'Test/Recursive/Data')) :
            TestTimezone.new(identifier, identifier == 'Test/No/Local')
      end
    end
  end
  
  def teardown
    # Re-require timezone to reset.
    # Suppress redefined method warnings.
    without_warnings do
      load 'tzinfo/timezone.rb'
    end
  end
  
  def test_identifier
    tz = LinkedTimezone.new(LinkedTimezoneInfo.new('Test/Zone', 'Test/Linked'))
    assert_equal('Test/Zone', tz.identifier)
  end
  
  def test_invalid_linked_identifier
    assert_raises(InvalidTimezoneIdentifier) { LinkedTimezone.new(LinkedTimezoneInfo.new('Test/Zone', 'Invalid/Identifier')) }
  end
  
  def test_period_for_utc
    tz = LinkedTimezone.new(LinkedTimezoneInfo.new('Test/Zone', 'Test/Linked'))
    linked_tz = Timezone.get('Test/Linked')
    t = Time.utc(2006, 6, 27, 23, 12, 28)
    assert_same(linked_tz.utc_period, tz.period_for_utc(t))
    assert_same(t, linked_tz.utc)
  end
  
  def test_periods_for_local
    tz = LinkedTimezone.new(LinkedTimezoneInfo.new('Test/Zone', 'Test/Linked'))
    linked_tz = Timezone.get('Test/Linked')
    t = Time.utc(2006, 6, 27, 23, 12, 28)
    assert_same(linked_tz.local_periods, tz.periods_for_local(t))
    assert_same(t, linked_tz.local)
  end
  
  def test_periods_for_local_not_found
    tz = LinkedTimezone.new(LinkedTimezoneInfo.new('Test/Zone', 'Test/No/Local'))
    linked_tz = Timezone.get('Test/No/Local')
    t = Time.utc(2006, 6, 27, 23, 12, 28)
    assert_raises(PeriodNotFound) { tz.periods_for_local(t) }
    assert_same(t, linked_tz.local)
  end
  
  def test_transitions_up_to
    tz = LinkedTimezone.new(LinkedTimezoneInfo.new('Test/Zone', 'Test/Linked'))
    linked_tz = Timezone.get('Test/Linked')
    utc_to = Time.utc(2013, 1, 1, 0, 0, 0)
    utc_from = Time.utc(2012, 1, 1, 0, 0, 0)
    assert_same(linked_tz.up_to_transitions, tz.transitions_up_to(utc_to, utc_from))
    assert_same(utc_to, linked_tz.utc_to)
    assert_same(utc_from, linked_tz.utc_from)
  end
  
  def test_canonical_identifier
    tz = LinkedTimezone.new(LinkedTimezoneInfo.new('Test/Zone', 'Test/Linked'))
    assert_equal('Test/Linked', tz.canonical_identifier)
  end
  
  def test_canonical_identifier_recursive
    # Recursive links are not currently used in the Time Zone database, but 
    # will be supported by TZInfo.
  
    tz = LinkedTimezone.new(LinkedTimezoneInfo.new('Test/Zone', 'Test/Recursive/Linked'))
    assert_equal('Test/Recursive/Data', tz.canonical_identifier)
  end
  
  def test_canonical_zone
    tz = LinkedTimezone.new(LinkedTimezoneInfo.new('Test/Zone', 'Test/Linked'))
    linked_tz = Timezone.get('Test/Linked')
    assert_same(linked_tz, tz.canonical_zone)
  end
  
  def test_canonical_zone_recursive
    # Recursive links are not currently used in the Time Zone database, but 
    # will be supported by TZInfo.
  
    tz = LinkedTimezone.new(LinkedTimezoneInfo.new('Test/Zone', 'Test/Recursive/Linked'))
    linked_tz = Timezone.get('Test/Recursive/Data')
    assert_same(linked_tz, tz.canonical_zone)
  end
end
