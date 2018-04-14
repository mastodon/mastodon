require File.join(File.expand_path(File.dirname(__FILE__)), 'test_utils')

include TZInfo

class TCCountryTimezone < Minitest::Test
  def test_identifier_new!
    ct = CountryTimezone.new!('Europe/London', 2059, 40, -5, 16)    
    assert_equal('Europe/London', ct.identifier)
  end
  
  def test_identifier_new
    ct = CountryTimezone.new('Europe/London', Rational(2059, 40), Rational(-5, 16))    
    assert_equal('Europe/London', ct.identifier)
  end
  
  def test_latitude_new!
    ct = CountryTimezone.new!('Europe/London', 2059, 40, -5, 16)
    assert_equal(Rational(2059, 40), ct.latitude)
  end

  def test_latitude_after_freeze_new!
    ct = CountryTimezone.new!('Europe/London', 2059, 40, -5, 16)
    ct.freeze
    assert_equal(Rational(2059, 40), ct.latitude)
  end
  
  def test_latitude_new
    ct = CountryTimezone.new('Europe/London', Rational(2059, 40), Rational(-5, 16))
    assert_equal(Rational(2059, 40), ct.latitude)
  end
  
  def test_longitude_new!
    ct = CountryTimezone.new!('Europe/London', 2059, 40, -5, 16)
    assert_equal(Rational(-5, 16), ct.longitude)
  end

  def test_longitude_after_freeze_new!
    ct = CountryTimezone.new!('Europe/London', 2059, 40, -5, 16)
    ct.freeze
    assert_equal(Rational(-5, 16), ct.longitude)
  end
  
  def test_longitude_new
    ct = CountryTimezone.new('Europe/London', Rational(2059, 40), Rational(-5, 16))
    assert_equal(Rational(-5, 16), ct.longitude)
  end
  
  def test_description_omit_new!
    ct = CountryTimezone.new!('Europe/London', 2059, 40, -5, 16)
    assert_nil(ct.description)
  end
  
  def test_description_omit_new
    ct = CountryTimezone.new('Europe/London', Rational(2059, 40), Rational(-5, 16))
    assert_nil(ct.description)
  end
  
  def test_description_nil_new!
    ct = CountryTimezone.new!('Europe/London', 2059, 40, -5, 16, nil)
    assert_nil(ct.description)
  end
  
  def test_description_nil_new
    ct = CountryTimezone.new('Europe/London', Rational(2059, 40), Rational(-5, 16), nil)
    assert_nil(ct.description)
  end
  
  def test_description_new!
    ct = CountryTimezone.new!('America/New_York', 48857, 1200, -266423, 3600, 'Eastern Time')
    assert_equal('Eastern Time', ct.description)
  end
  
  def test_description_new
    ct = CountryTimezone.new('America/New_York', Rational(48857, 1200), Rational(-266423, 3600), 'Eastern Time')
    assert_equal('Eastern Time', ct.description)
  end
  
  def test_timezone    
    ct = CountryTimezone.new('Europe/London', Rational(2059, 40), Rational(-5, 16))
    assert_kind_of(TimezoneProxy, ct.timezone)
    assert_equal('Europe/London', ct.timezone.identifier)
  end
  
  def test_description_or_friendly_idenfier_no_description
    ct = CountryTimezone.new('Europe/London', Rational(2059, 40), Rational(-5, 16))
    assert_equal('London', ct.description_or_friendly_identifier)
  end
  
  def test_description_or_friendly_idenfier_description
    ct = CountryTimezone.new('America/New_York', Rational(48857, 1200), Rational(-266423, 3600), 'Eastern Time')
    assert_equal('Eastern Time', ct.description_or_friendly_identifier)
  end
  
  def test_equality_1
    ct1 = CountryTimezone.new!('Europe/London', 2059, 40, -5, 16)
    ct2 = CountryTimezone.new!('Europe/London', 2059, 40, -5, 16)
    ct3 = CountryTimezone.new('Europe/London', Rational(2059, 40), Rational(-5, 16))
    ct4 = CountryTimezone.new!('Europe/London', 2059, 40, -5, 16, 'Description')
    ct5 = CountryTimezone.new!('Europe/LondonB', 2059, 40, -5, 16)
    ct6 = CountryTimezone.new!('Europe/London', 2060, 40, -5, 16)
    ct7 = CountryTimezone.new!('Europe/London', 2059, 40, -6, 16)
    
    assert_equal(true, ct1 == ct1)
    assert_equal(true, ct1 == ct2)
    assert_equal(true, ct1 == ct3)
    assert_equal(false, ct1 == ct4)
    assert_equal(false, ct1 == ct5)
    assert_equal(false, ct1 == ct6)
    assert_equal(false, ct1 == ct7)
  end
  
  def test_equality_2
    ct1 = CountryTimezone.new!('America/New_York', 48857, 1200, -266423, 3600, 'Eastern Time')
    ct2 = CountryTimezone.new!('America/New_York', 48857, 1200, -266423, 3600, 'Eastern Time2')
    
    assert_equal(true, ct1 == ct1)
    assert_equal(false, ct1 == ct2)    
  end
  
  def test_equality_non_country_timezone
    ct = CountryTimezone.new('Europe/London', Rational(2059, 40), Rational(-5, 16))
    
    assert_equal(false, ct == Object.new)
  end
  
  def test_eql_1
    ct1 = CountryTimezone.new!('Europe/London', 2059, 40, -5, 16)
    ct2 = CountryTimezone.new!('Europe/London', 2059, 40, -5, 16)
    ct3 = CountryTimezone.new('Europe/London', Rational(2059, 40), Rational(-5, 16))
    ct4 = CountryTimezone.new!('Europe/London', 2059, 40, -5, 16, 'Description')
    ct5 = CountryTimezone.new!('Europe/LondonB', 2059, 40, -5, 16)
    ct6 = CountryTimezone.new!('Europe/London', 2060, 40, -5, 16)
    ct7 = CountryTimezone.new!('Europe/London', 2059, 40, -6, 16)
    
    assert_equal(true, ct1.eql?(ct1))
    assert_equal(true, ct1.eql?(ct2))
    assert_equal(true, ct1.eql?(ct3))
    assert_equal(false, ct1.eql?(ct4))
    assert_equal(false, ct1.eql?(ct5))
    assert_equal(false, ct1.eql?(ct6))
    assert_equal(false, ct1.eql?(ct7))
  end
  
  def test_eql_2
    ct1 = CountryTimezone.new!('America/New_York', 48857, 1200, -266423, 3600, 'Eastern Time')
    ct2 = CountryTimezone.new!('America/New_York', 48857, 1200, -266423, 3600, 'Eastern Time2')
    
    assert_equal(true, ct1.eql?(ct1))
    assert_equal(false, ct1.eql?(ct2))    
  end
  
  def test_eql_non_country_timezone
    ct = CountryTimezone.new('Europe/London', Rational(2059, 40), Rational(-5, 16))
    
    assert_equal(false, ct.eql?(Object.new))
  end
  
  def test_hash_new!
    ct1 = CountryTimezone.new!('Europe/London', 2059, 40, -5, 16)
    ct2 = CountryTimezone.new!('America/New_York', 48857, 1200, -266423, 3600, 'Eastern Time')
    
    assert_equal('Europe/London'.hash ^ 2059.hash ^ 40.hash ^ -5.hash ^ 16.hash ^ nil.hash, ct1.hash)
    assert_equal('America/New_York'.hash ^ 48857.hash ^ 1200.hash ^ -266423.hash ^ 3600.hash ^ 'Eastern Time'.hash, ct2.hash)
  end
  
  def test_hash_new
    ct1 = CountryTimezone.new('Europe/London', Rational(2059, 40), Rational(-5, 16))
    ct2 = CountryTimezone.new('America/New_York', Rational(48857, 1200), Rational(-266423, 3600), 'Eastern Time')
    
    assert_equal('Europe/London'.hash ^ 2059.hash ^ 40.hash ^ -5.hash ^ 16.hash ^ nil.hash, ct1.hash)
    assert_equal('America/New_York'.hash ^ 48857.hash ^ 1200.hash ^ -266423.hash ^ 3600.hash ^ 'Eastern Time'.hash, ct2.hash)
  end
end
