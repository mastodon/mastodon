require File.join(File.expand_path(File.dirname(__FILE__)), 'test_utils')

include TZInfo

class TCZoneinfoCountryInfo < Minitest::Test
  
  def test_code
    ci = ZoneinfoCountryInfo.new('ZZ', 'Zzz', []) {|c| }
    assert_equal('ZZ', ci.code)
  end
  
  def test_name
    ci = ZoneinfoCountryInfo.new('ZZ', 'Zzz', []) {|c| }
    assert_equal('Zzz', ci.name)
  end
  
  def test_zone_identifiers_empty
    ci = ZoneinfoCountryInfo.new('ZZ', 'Zzz', []) {|c| }
    assert(ci.zone_identifiers.empty?)
    assert(ci.zone_identifiers.frozen?)
  end
  
  def test_zone_identifiers
    zones = [
      CountryTimezone.new('ZZ/TimezoneB', Rational(1, 2), Rational(1, 2), 'Timezone B'),
      CountryTimezone.new('ZZ/TimezoneA', Rational(1, 4), Rational(1, 4), 'Timezone A'),
      CountryTimezone.new('ZZ/TimezoneC', Rational(-10, 3), Rational(-20, 7), 'C'),
      CountryTimezone.new('ZZ/TimezoneD', Rational(-10, 3), Rational(-20, 7))
    ]
  
    ci = ZoneinfoCountryInfo.new('ZZ', 'Zzz', zones)
    
    assert_equal(['ZZ/TimezoneB', 'ZZ/TimezoneA', 'ZZ/TimezoneC', 'ZZ/TimezoneD'], ci.zone_identifiers)
    assert(ci.zone_identifiers.frozen?)
    assert(!ci.zones.equal?(zones))
    assert(!zones.frozen?)
  end

  def test_zone_identifiers_after_freeze
    zones = [
      CountryTimezone.new('ZZ/TimezoneB', Rational(1, 2), Rational(1, 2), 'Timezone B'),
      CountryTimezone.new('ZZ/TimezoneA', Rational(1, 4), Rational(1, 4), 'Timezone A'),
      CountryTimezone.new('ZZ/TimezoneC', Rational(-10, 3), Rational(-20, 7), 'C'),
      CountryTimezone.new('ZZ/TimezoneD', Rational(-10, 3), Rational(-20, 7))
    ]

    ci = ZoneinfoCountryInfo.new('ZZ', 'Zzz', zones)
    ci.freeze

    assert_equal(['ZZ/TimezoneB', 'ZZ/TimezoneA', 'ZZ/TimezoneC', 'ZZ/TimezoneD'], ci.zone_identifiers)
  end
  
  def test_zones_empty
    ci = ZoneinfoCountryInfo.new('ZZ', 'Zzz', [])
    assert(ci.zones.empty?)
    assert(ci.zones.frozen?)
  end
  
  def test_zones
    zones = [
      CountryTimezone.new('ZZ/TimezoneB', Rational(1, 2), Rational(1, 2), 'Timezone B'),
      CountryTimezone.new('ZZ/TimezoneA', Rational(1, 4), Rational(1, 4), 'Timezone A'),
      CountryTimezone.new('ZZ/TimezoneC', Rational(-10, 3), Rational(-20, 7), 'C'),
      CountryTimezone.new('ZZ/TimezoneD', Rational(-10, 3), Rational(-20, 7))
    ]
  
    ci = ZoneinfoCountryInfo.new('ZZ', 'Zzz', zones)
    
    assert_equal([CountryTimezone.new('ZZ/TimezoneB', Rational(1, 2), Rational(1, 2), 'Timezone B'),
      CountryTimezone.new('ZZ/TimezoneA', Rational(1, 4), Rational(1, 4), 'Timezone A'),
      CountryTimezone.new('ZZ/TimezoneC', Rational(-10, 3), Rational(-20, 7), 'C'),
      CountryTimezone.new('ZZ/TimezoneD', Rational(-10, 3), Rational(-20, 7))],
      ci.zones)
    assert(ci.zones.frozen?)
    assert(!ci.zones.equal?(zones))
    assert(!zones.frozen?)
  end
end
