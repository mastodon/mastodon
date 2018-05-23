require File.join(File.expand_path(File.dirname(__FILE__)), 'test_utils')

include TZInfo

class TCRubyCountryInfo < Minitest::Test
  
  def test_code
    ci = RubyCountryInfo.new('ZZ', 'Zzz') {|c| }
    assert_equal('ZZ', ci.code)
  end
  
  def test_name
    ci = RubyCountryInfo.new('ZZ', 'Zzz') {|c| }
    assert_equal('Zzz', ci.name)
  end
  
  def test_zone_identifiers_empty
    ci = RubyCountryInfo.new('ZZ', 'Zzz') {|c| }
    assert(ci.zone_identifiers.empty?)
    assert(ci.zone_identifiers.frozen?)
  end
  
  def test_zone_identifiers_no_block
    ci = RubyCountryInfo.new('ZZ', 'Zzz')
    assert(ci.zone_identifiers.empty?)
    assert(ci.zone_identifiers.frozen?)
  end
  
  def test_zone_identifiers
    ci = RubyCountryInfo.new('ZZ', 'Zzz') do |c|
      c.timezone('ZZ/TimezoneB', 1, 2, 1, 2, 'Timezone B')
      c.timezone('ZZ/TimezoneA', 1, 4, 1, 4, 'Timezone A')
      c.timezone('ZZ/TimezoneC', -10, 3, -20, 7, 'C')
      c.timezone('ZZ/TimezoneD', -10, 3, -20, 7)
    end
    
    assert_equal(['ZZ/TimezoneB', 'ZZ/TimezoneA', 'ZZ/TimezoneC', 'ZZ/TimezoneD'], ci.zone_identifiers)
    assert(ci.zone_identifiers.frozen?)
  end

  def test_zone_identifiers_after_freeze
    ci = RubyCountryInfo.new('ZZ', 'Zzz') do |c|
      c.timezone('ZZ/TimezoneB', 1, 2, 1, 2, 'Timezone B')
      c.timezone('ZZ/TimezoneA', 1, 4, 1, 4, 'Timezone A')
      c.timezone('ZZ/TimezoneC', -10, 3, -20, 7, 'C')
      c.timezone('ZZ/TimezoneD', -10, 3, -20, 7)
    end

    ci.freeze

    assert_equal(['ZZ/TimezoneB', 'ZZ/TimezoneA', 'ZZ/TimezoneC', 'ZZ/TimezoneD'], ci.zone_identifiers)
  end
  
  def test_zones_empty
    ci = RubyCountryInfo.new('ZZ', 'Zzz') {|c| }
    assert(ci.zones.empty?)
    assert(ci.zones.frozen?)
  end
  
  def test_zones_no_block
    ci = RubyCountryInfo.new('ZZ', 'Zzz')
    assert(ci.zones.empty?)
    assert(ci.zones.frozen?)
  end
  
  def test_zones
    ci = RubyCountryInfo.new('ZZ', 'Zzz') do |c|
      c.timezone('ZZ/TimezoneB', 1, 2, 1, 2, 'Timezone B')
      c.timezone('ZZ/TimezoneA', 1, 4, 1, 4, 'Timezone A')
      c.timezone('ZZ/TimezoneC', -10, 3, -20, 7, 'C')
      c.timezone('ZZ/TimezoneD', -10, 3, -20, 7)
    end
    
    assert_equal([CountryTimezone.new!('ZZ/TimezoneB', 1, 2, 1, 2, 'Timezone B'),
      CountryTimezone.new!('ZZ/TimezoneA', 1, 4, 1, 4, 'Timezone A'),
      CountryTimezone.new!('ZZ/TimezoneC', -10, 3, -20, 7, 'C'),
      CountryTimezone.new!('ZZ/TimezoneD', -10, 3, -20, 7)],
      ci.zones)
    assert(ci.zones.frozen?)
  end

  def test_zones_after_freeze
    ci = RubyCountryInfo.new('ZZ', 'Zzz') do |c|
      c.timezone('ZZ/TimezoneB', 1, 2, 1, 2, 'Timezone B')
      c.timezone('ZZ/TimezoneA', 1, 4, 1, 4, 'Timezone A')
      c.timezone('ZZ/TimezoneC', -10, 3, -20, 7, 'C')
      c.timezone('ZZ/TimezoneD', -10, 3, -20, 7)
    end

    ci.freeze

    assert_equal([CountryTimezone.new!('ZZ/TimezoneB', 1, 2, 1, 2, 'Timezone B'),
      CountryTimezone.new!('ZZ/TimezoneA', 1, 4, 1, 4, 'Timezone A'),
      CountryTimezone.new!('ZZ/TimezoneC', -10, 3, -20, 7, 'C'),
      CountryTimezone.new!('ZZ/TimezoneD', -10, 3, -20, 7)],
      ci.zones)
  end
  
  def test_deferred_evaluate
    block_called = false
    
    ci = RubyCountryInfo.new('ZZ', 'Zzz') do |c|
      block_called = true
    end
    
    assert_equal(false, block_called)
    ci.zones
    assert_equal(true, block_called)
  end
end
