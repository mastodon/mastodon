require File.join(File.expand_path(File.dirname(__FILE__)), 'test_utils')

include TZInfo

class TCCountryIndexDefinition < Minitest::Test

  module CountriesTest1     
    include CountryIndexDefinition
    
    country 'ZZ', 'Country One' do |c|
      c.timezone 'Test/Zone/1', 3, 2, 41,20
    end
    
    country 'AA', 'Aland' do |c|
      c.timezone 'Test/Zone/3', 71,30, 358, 15
      c.timezone 'Test/Zone/2', 41, 20, 211, 30
    end
    
    country 'TE', 'Three'    
  end
  
  module CountriesTest2
    include CountryIndexDefinition
    
    country 'CO', 'First Country' do |c|
    end
  end
  
  def test_module_1
    hash = CountriesTest1.countries
    assert_equal(3, hash.length)
    assert_equal(true, hash.frozen?)
    
    zz = hash['ZZ']
    aa = hash['AA']
    te = hash['TE']
    
    assert_kind_of(RubyCountryInfo, zz)
    assert_equal('ZZ', zz.code)
    assert_equal('Country One', zz.name)
    assert_equal(1, zz.zones.length)
    assert_equal('Test/Zone/1', zz.zones[0].identifier)
    
    assert_kind_of(RubyCountryInfo, aa)
    assert_equal('AA', aa.code)
    assert_equal('Aland', aa.name)
    assert_equal(2, aa.zones.length)
    assert_equal('Test/Zone/3', aa.zones[0].identifier)
    assert_equal('Test/Zone/2', aa.zones[1].identifier)
    
    assert_kind_of(RubyCountryInfo, te)
    assert_equal('TE', te.code)
    assert_equal('Three', te.name)
    assert_equal(0, te.zones.length)    
  end
  
  def test_module_2
    hash = CountriesTest2.countries
    assert_equal(1, hash.length)
    assert_equal(true, hash.frozen?)
    
    co = hash['CO']
    
    assert_kind_of(RubyCountryInfo, co)
    assert_equal('CO', co.code)
    assert_equal('First Country', co.name)
    assert_equal(0, co.zones.length)
  end  
end
