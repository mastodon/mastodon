require File.join(File.expand_path(File.dirname(__FILE__)), 'test_utils')

include TZInfo

class TCTimezoneProxy < Minitest::Test
  def test_not_exist
    proxy = TimezoneProxy.new('Nothing/Special')
    t = Time.utc(2006,1,1,0,0,0)
    assert_equal('Nothing/Special', proxy.identifier)
    assert_equal('Nothing/Special', proxy.name)
    assert_equal('Nothing - Special', proxy.friendly_identifier)
    assert_equal('Nothing - Special', proxy.to_s)

    assert_raises(InvalidTimezoneIdentifier) { proxy.canonical_identifier }
    assert_raises(InvalidTimezoneIdentifier) { proxy.canonical_zone }
    assert_raises(InvalidTimezoneIdentifier) { proxy.current_period }
    assert_raises(InvalidTimezoneIdentifier) { proxy.current_period_and_time }
    assert_raises(InvalidTimezoneIdentifier) { proxy.current_time_and_period }
    assert_raises(InvalidTimezoneIdentifier) { proxy.local_to_utc(t) }
    assert_raises(InvalidTimezoneIdentifier) { proxy.now }
    assert_raises(InvalidTimezoneIdentifier) { proxy.offsets_up_to(t) }
    assert_raises(InvalidTimezoneIdentifier) { proxy.period_for_local(t) }
    assert_raises(InvalidTimezoneIdentifier) { proxy.period_for_utc(t) }
    assert_raises(InvalidTimezoneIdentifier) { proxy.periods_for_local(t) }
    assert_raises(InvalidTimezoneIdentifier) { proxy.strftime('%Z', t) }
    assert_raises(InvalidTimezoneIdentifier) { proxy.transitions_up_to(t) }
    assert_raises(InvalidTimezoneIdentifier) { proxy.utc_to_local(t) }
  end
  
  def test_valid
    proxy = TimezoneProxy.new('Europe/London')
    real = Timezone.get('Europe/London')

    t1 = Time.utc(2005,8,1,0,0,0)
    t2 = Time.utc(2004,8,1,0,0,0)

    assert_equal(real.canonical_identifier, proxy.canonical_identifier)
    assert_same(real.canonical_zone, proxy.canonical_zone)
    assert_nothing_raised { proxy.current_period }
    assert_nothing_raised { proxy.current_period_and_time }
    assert_nothing_raised { proxy.current_time_and_period }
    assert_equal(real.friendly_identifier(true), proxy.friendly_identifier(true))
    assert_equal(real.friendly_identifier(false), proxy.friendly_identifier(false))
    assert_equal(real.friendly_identifier, proxy.friendly_identifier)
    assert_equal(real.identifier, proxy.identifier)
    assert_equal(real.local_to_utc(t1), proxy.local_to_utc(t1))
    assert_equal(real.name, proxy.name)
    assert_nothing_raised { proxy.now }
    assert_equal(real.offsets_up_to(t1), proxy.offsets_up_to(t1))
    assert_equal(real.offsets_up_to(t1, t2), proxy.offsets_up_to(t1, t2))
    assert_equal(real.period_for_local(t1), proxy.period_for_local(t1))
    assert_equal(real.period_for_utc(t1), proxy.period_for_utc(t1))
    assert_equal(real.periods_for_local(t1), proxy.periods_for_local(t1))
    assert_equal(real.strftime('%Z', t1), proxy.strftime('%Z', t1))
    assert_equal(real.to_s, proxy.to_s)
    assert_equal(real.transitions_up_to(t1), proxy.transitions_up_to(t1))
    assert_equal(real.transitions_up_to(t1, t2), proxy.transitions_up_to(t1, t2))
    assert_equal(real.utc_to_local(t1), proxy.utc_to_local(t1))


    assert(real == proxy)
    assert(proxy == real)
    assert_equal(0, real <=> proxy)
    assert_equal(0, proxy <=> real)
  end
  
  def test_canonical_linked
    # Test that the implementation of canonical_zone and canonical_identifier
    # are actually calling the real timezone and not just returning it and
    # its identifier.
    
    real = Timezone.get('UTC')
    proxy = TimezoneProxy.new('UTC')
    
    # ZoneinfoDataSource doesn't return LinkedTimezoneInfo instances for any 
    # timezone.
    if real.kind_of?(LinkedTimezone)
      assert_equal('Etc/UTC', proxy.canonical_identifier)
      assert_same(Timezone.get('Etc/UTC'), proxy.canonical_zone)
    else    
      if DataSource.get.kind_of?(RubyDataSource)
        # Not got a LinkedTimezone despite using a DataSource that supports it.
        # Raise an exception as this shouldn't happen.
        raise 'Non-LinkedTimezone instance returned for UTC using RubyDataSource'
      end
      
      assert_equal('UTC', proxy.canonical_identifier)
      assert_same(Timezone.get('UTC'), proxy.canonical_zone)
    end
  end

  def test_after_freeze
    proxy = TimezoneProxy.new('Europe/London')
    real = Timezone.get('Europe/London')
    t = Time.utc(2017, 6, 1)
    proxy.freeze
    assert_equal('Europe/London', proxy.identifier)
    assert_equal(real.utc_to_local(t), proxy.utc_to_local(t))
  end
  
  def test_equals
    assert_equal(true, TimezoneProxy.new('Europe/London') == TimezoneProxy.new('Europe/London'))
    assert_equal(false, TimezoneProxy.new('Europe/London') == TimezoneProxy.new('Europe/Paris'))
    assert(!(TimezoneProxy.new('Europe/London') == Object.new))
  end
  
  def test_compare
    assert_equal(0, TimezoneProxy.new('Europe/London') <=> TimezoneProxy.new('Europe/London'))
    assert_equal(0, Timezone.get('Europe/London') <=> TimezoneProxy.new('Europe/London'))
    assert_equal(0, TimezoneProxy.new('Europe/London') <=> Timezone.get('Europe/London'))
    assert_equal(-1, TimezoneProxy.new('Europe/London') <=> TimezoneProxy.new('Europe/Paris'))
    assert_equal(-1, Timezone.get('Europe/London') <=> TimezoneProxy.new('Europe/Paris'))
    assert_equal(-1, TimezoneProxy.new('Europe/London') <=> Timezone.get('Europe/Paris'))
    assert_equal(1, TimezoneProxy.new('Europe/Paris') <=> TimezoneProxy.new('Europe/London'))
    assert_equal(1, Timezone.get('Europe/Paris') <=> TimezoneProxy.new('Europe/London'))
    assert_equal(1, TimezoneProxy.new('Europe/Paris') <=> Timezone.get('Europe/London'))
    assert_equal(-1, TimezoneProxy.new('America/New_York') <=> TimezoneProxy.new('Europe/Paris'))
    assert_equal(-1, Timezone.get('America/New_York') <=> TimezoneProxy.new('Europe/Paris'))
    assert_equal(-1, TimezoneProxy.new('America/New_York') <=> Timezone.get('Europe/Paris'))
    assert_equal(1, TimezoneProxy.new('Europe/Paris') <=> TimezoneProxy.new('America/New_York'))
    assert_equal(1, Timezone.get('Europe/Paris') <=> TimezoneProxy.new('America/New_York'))
    assert_equal(1, TimezoneProxy.new('Europe/Paris') <=> Timezone.get('America/New_York'))
  end
  
  def test_kind
    assert_kind_of(Timezone, TimezoneProxy.new('America/New_York'))
  end
  
  def test_marshal
    tp = TimezoneProxy.new('Europe/London')
    tp2 = Marshal.load(Marshal.dump(tp))
    
    assert_kind_of(TimezoneProxy, tp2)
    assert_equal('Europe/London', tp2.identifier)
  end
end
