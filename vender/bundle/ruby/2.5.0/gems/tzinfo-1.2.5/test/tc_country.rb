require File.join(File.expand_path(File.dirname(__FILE__)), 'test_utils')

include TZInfo

class TCCountry < Minitest::Test
  def setup
    @orig_data_source = DataSource.get
    Country.send :init_countries
  end
  
  def teardown
    DataSource.set(@orig_data_source)
  end
  
  def test_get_valid
    c = Country.get('GB')
    
    assert c
    assert_equal('GB', c.code)
  end
    
  def test_get_not_exist
    assert_raises(InvalidCountryCode) {
      Country.get('ZZ')
    }
  end
  
  def test_get_invalid
    assert_raises(InvalidCountryCode) {
      Country.get('../Countries/GB')
    }
  end
  
  def test_get_nil
    assert_raises(InvalidCountryCode) {
      Country.get(nil)
    }
  end
  
  def test_get_case    
    assert_raises(InvalidCountryCode) {
      Country.get('gb')
    }
  end
  
  def test_get_tainted_loaded
    Country.get('GB')
  
    safe_test do
      code = 'GB'.dup.taint
      assert(code.tainted?)
      country = Country.get(code)
      assert_equal('GB', country.code)
      assert(code.tainted?)
    end
  end
  
  def test_get_tainted_and_frozen_loaded
    Country.get('GB')
  
    safe_test do
      country = Country.get('GB'.dup.taint.freeze)
      assert_equal('GB', country.code)
    end
  end
  
  def test_get_tainted_not_previously_loaded
    safe_test do
      code = 'GB'.dup.taint
      assert(code.tainted?)
      country = Country.get(code)
      assert_equal('GB', country.code)
      assert(code.tainted?)
    end
  end
  
  def test_get_tainted_and_frozen_not_previously_loaded
    safe_test do
      country = Country.get('GB'.dup.taint.freeze)
      assert_equal('GB', country.code)
    end
  end
    
  def test_new_nil
    assert_raises(InvalidCountryCode) {
      Country.new(nil)
    }        
  end
  
  def test_new_arg
    c = Country.new('GB')
    assert_same(Country.get('GB'), c)    
  end
  
  def test_new_arg_not_exist    
    assert_raises(InvalidCountryCode) {
      Country.new('ZZ')
    }
  end 
  
  def test_all_codes
    all_codes = Country.all_codes
    assert_kind_of(Array, all_codes)
  end
  
  def test_all
    all = Country.all    
    assert_equal(Country.all_codes, all.collect {|c| c.code})
  end
  
  def test_code    
    assert_equal('US', Country.get('US').code)
  end
  
  def test_name
    assert_kind_of(String, Country.get('US').name)
  end
  
  def test_to_s
    assert_equal(Country.get('US').name, Country.get('US').to_s)
    assert_equal(Country.get('GB').name, Country.get('GB').to_s)
  end
  
  def test_zone_identifiers
    zone_names = Country.get('US').zone_names
    assert_kind_of(Array, zone_names)
    assert_equal(true, zone_names.frozen?)    
  end
  
  def test_zone_names
    assert_equal(Country.get('US').zone_identifiers, Country.get('US').zone_names)
  end
  
  def test_zones
    zones = Country.get('US').zones
    assert_kind_of(Array, zones)    
    assert_equal(Country.get('US').zone_identifiers, zones.collect {|z| z.identifier})
    
    zones.each {|z| assert_kind_of(TimezoneProxy, z)}
  end
  
  def test_zone_info
    zones = Country.get('US').zone_info
    assert_kind_of(Array, zones)
    assert_equal(true, zones.frozen?)
    
    assert_equal(Country.get('US').zone_identifiers, zones.collect {|z| z.identifier})
    assert_equal(Country.get('US').zone_identifiers, zones.collect {|z| z.timezone.identifier})
    
    zones.each {|z| assert_kind_of(CountryTimezone, z)}
  end  
      
  def test_compare
    assert_equal(0, Country.get('GB') <=> Country.get('GB'))
    assert_equal(-1, Country.get('GB') <=> Country.get('US'))
    assert_equal(1, Country.get('US') <=> Country.get('GB'))
    assert_equal(-1, Country.get('FR') <=> Country.get('US'))
    assert_equal(1, Country.get('US') <=> Country.get('FR'))
  end
  
  def test_compare_non_comparable
    assert_nil(Country.get('GB') <=> Object.new)
  end
  
  def test_equality
    assert_equal(true, Country.get('GB') == Country.get('GB'))
    assert_equal(false, Country.get('GB') == Country.get('US'))
    assert(!(Country.get('GB') == Object.new))
  end
  
  def test_eql
    assert_equal(true, Country.get('GB').eql?(Country.get('GB')))
    assert_equal(false, Country.get('GB').eql?(Country.get('US')))
    assert(!Country.get('GB').eql?(Object.new))
  end
  
  def test_hash
    assert_equal('GB'.hash, Country.get('GB').hash)
    assert_equal('US'.hash, Country.get('US').hash)
  end
  
  def test_marshal
    c = Country.get('US')
    
    # Should get back the same instance because load calls Country.get.
    assert_same(c, Marshal.load(Marshal.dump(c)))
  end
  
  def test_reload
    # If country gets reloaded for some reason, it needs to force a reload of
    # the country index.
    
    assert_equal('US', Country.get('US').code)

    # Suppress redefined method warnings.
    without_warnings do
      load 'tzinfo/country.rb'
    end
    
    assert_equal('US', Country.get('US').code)
  end
  
  def test_get_missing_data_source
    DataSource.set(DataSource.new)
    
    assert_raises(InvalidDataSource) do
      Country.get('GB')
    end
  end
  
  def test_new_missing_data_source
    DataSource.set(DataSource.new)
    
    assert_raises(InvalidDataSource) do
      Country.new('GB')
    end
  end
  
  def test_all_codes_missing_data_source
    DataSource.set(DataSource.new)
    
    assert_raises(InvalidDataSource) do
      Country.all_codes
    end
  end
  
  def test_all_missing_data_source
    DataSource.set(DataSource.new)
    
    assert_raises(InvalidDataSource) do
      Country.all
    end
  end
end
