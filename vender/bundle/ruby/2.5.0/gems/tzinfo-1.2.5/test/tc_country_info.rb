require File.join(File.expand_path(File.dirname(__FILE__)), 'test_utils')

include TZInfo

class TCCountryInfo < Minitest::Test
  
  def test_code
    ci = CountryInfo.new('ZZ', 'Zzz') {|c| }
    assert_equal('ZZ', ci.code)
  end
  
  def test_name
    ci = CountryInfo.new('ZZ', 'Zzz') {|c| }
    assert_equal('Zzz', ci.name)
  end
end
