# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), 'test_utils')

include TZInfo

class TCRubyCoreSupport < Minitest::Test
  def test_rational_new!
    assert_equal(Rational(3,4), RubyCoreSupport.rational_new!(3,4))
  end
  
  def test_datetime_new!
    assert_equal(DateTime.new(2008,10,5,12,0,0, 0, Date::ITALY), RubyCoreSupport.datetime_new!(2454745,0,2299161))
    assert_equal(DateTime.new(2008,10,5,13,0,0, Rational(1, 24), Date::ITALY), RubyCoreSupport.datetime_new!(2454745,Rational(1, 24),2299161))
    
    assert_equal(DateTime.new(2008,10,5,20,30,0, 0, Date::ITALY), RubyCoreSupport.datetime_new!(Rational(117827777, 48), 0, 2299161))
    assert_equal(DateTime.new(2008,10,5,21,30,0, Rational(1, 24), Date::ITALY), RubyCoreSupport.datetime_new!(Rational(117827777, 48), Rational(1, 24), 2299161))
    
    assert_equal(DateTime.new(2008,10,6,6,26,21, 0, Date::ITALY), RubyCoreSupport.datetime_new!(Rational(70696678127,28800), 0, 2299161))
    assert_equal(DateTime.new(2008,10,6,7,26,21, Rational(1, 24), Date::ITALY), RubyCoreSupport.datetime_new!(Rational(70696678127, 28800), Rational(1, 24), 2299161))
    
    assert_equal(DateTime.new(-4712,1,1,12,0,0, 0, Date::ITALY), RubyCoreSupport.datetime_new!(0, 0, 2299161))
    assert_equal(DateTime.new(-4712,1,1,13,0,0, Rational(1, 24), Date::ITALY), RubyCoreSupport.datetime_new!(0, Rational(1, 24), 2299161))
    
    assert_equal(DateTime.new(-4713,12,31,23,58,59, 0, Date::ITALY), RubyCoreSupport.datetime_new!(Rational(-43261, 86400), 0, 2299161))
    assert_equal(DateTime.new(-4712,1,1,0,58,59, Rational(1, 24), Date::ITALY), RubyCoreSupport.datetime_new!(Rational(-43261, 86400), Rational(1, 24), 2299161))
    
    assert_equal(DateTime.new(-4713,12,30,23,58,59, 0, Date::ITALY), RubyCoreSupport.datetime_new!(Rational(-129661, 86400), 0, 2299161))
    assert_equal(DateTime.new(-4713,12,31,0,58,59, Rational(1, 24), Date::ITALY), RubyCoreSupport.datetime_new!(Rational(-129661, 86400), Rational(1, 24), 2299161))
  end
  
  def test_datetime_new
    assert_equal(DateTime.new(2012, 12, 31, 23, 59, 59, 0, Date::ITALY), RubyCoreSupport.datetime_new(2012, 12, 31, 23, 59, 59, 0, Date::ITALY))
    assert_equal(DateTime.new(2013, 2, 6, 23, 2, 36, Rational(1, 24), Date::ITALY), RubyCoreSupport.datetime_new(2013, 2, 6, 23, 2, 36, Rational(1,24), Date::ITALY))
    
    assert_equal(DateTime.new(2012, 12, 31, 23, 59, 59, 0, Date::ITALY) + Rational(1, 86400000), RubyCoreSupport.datetime_new(2012, 12, 31, 23, 59, 59 + Rational(1, 1000), 0, Date::ITALY))
    assert_equal(DateTime.new(2001, 10, 12, 12, 22, 59, Rational(1, 24), Date::ITALY) + Rational(501, 86400000), RubyCoreSupport.datetime_new(2001, 10, 12, 12, 22, 59 + Rational(501, 1000), Rational(1, 24), Date::ITALY))
  end
  
  def test_time_supports_negative
    if RubyCoreSupport.time_supports_negative
      assert_equal(Time.utc(1969, 12, 31, 23, 59, 59), Time.at(-1).utc)
    else
      assert_raises(ArgumentError) do
        Time.at(-1)
      end
    end
  end
  
  def test_time_supports_64_bit
    if RubyCoreSupport.time_supports_64bit
      assert_equal(Time.utc(1901, 12, 13, 20, 45, 51), Time.at(-2147483649).utc)
      assert_equal(Time.utc(2038, 1, 19, 3, 14, 8), Time.at(2147483648).utc)
    else
      assert_raises(RangeError) do
        Time.at(-2147483649)
      end
      
      assert_raises(RangeError) do
        Time.at(2147483648)
      end
    end
  end
  
  def test_time_nsec
    t = Time.utc(2013, 2, 6, 21, 56, 23, 567890 + Rational(123,1000))
    
    if t.respond_to?(:nsec)
      assert_equal(567890123, RubyCoreSupport.time_nsec(t))
    else
      assert_equal(567890000, RubyCoreSupport.time_nsec(t))
    end
  end
  
  def test_force_encoding
    s = [0xC2, 0xA9].pack('c2')
    
    if s.respond_to?(:force_encoding)
      # Ruby 1.9+ - should call String#force_encoding
      assert_equal('ASCII-8BIT', s.encoding.name)
      assert_equal(2, s.bytesize)
      result = RubyCoreSupport.force_encoding(s, 'UTF-8')
      assert_same(s, result)
      assert_equal('UTF-8', s.encoding.name)
      assert_equal(2, s.bytesize)
      assert_equal(1, s.length)
      assert_equal('©', s)
    else
      # Ruby 1.8 - no-op
      result = RubyCoreSupport.force_encoding(s, 'UTF-8')
      assert_same(s, result)
      assert_equal('©', s)
    end
  end
  
  begin
    SUPPORTS_ENCODING = !!Encoding
  rescue NameError
    SUPPORTS_ENCODING = false
  end

  def check_open_file_test_file_bytes(test_file)
    if SUPPORTS_ENCODING
      File.open(test_file, 'r') do |file|
        file.binmode
        data = file.read(2)
        refute_nil(data)
        assert_equal(2, data.length)
        bytes = data.unpack('C2')
        assert_equal(0xC2, bytes[0])
        assert_equal(0xA9, bytes[1])
      end
    end
  end
  
  def check_open_file_test_file_content(file)
    content = file.gets
    refute_nil(content)
    content.chomp!
    
    if SUPPORTS_ENCODING            
      assert_equal('UTF-8', content.encoding.name)
      assert_equal(1, content.length)
      assert_equal(2, content.bytesize) 
      assert_equal('©', content)
    else
      assert_equal('x', content)
    end
  end

  def test_open_file
    Dir.mktmpdir('tzinfo_test') do |dir|          
      test_file = File.join(dir, 'test.txt')
    
      file = RubyCoreSupport.open_file(test_file, 'w', :external_encoding => 'UTF-8')
      begin        
        file.puts(SUPPORTS_ENCODING ? '©' : 'x')
      ensure
        file.close
      end
      
      check_open_file_test_file_bytes(test_file)
      
      file = RubyCoreSupport.open_file(test_file, 'r', :external_encoding => 'UTF-8', :internal_encoding => 'UTF-8')
      begin
        check_open_file_test_file_content(file)
      ensure
        file.close
      end
    end
  end
    
  def test_open_file_block
    Dir.mktmpdir('tzinfo_test') do |dir|          
      test_file = File.join(dir, 'test.txt')
    
      RubyCoreSupport.open_file(test_file, 'w', :external_encoding => 'UTF-8') do |file|
        file.puts(SUPPORTS_ENCODING ? '©' : 'x')
      end
      
      check_open_file_test_file_bytes(test_file)
      
      RubyCoreSupport.open_file(test_file, 'r', :external_encoding => 'UTF-8', :internal_encoding => 'UTF-8') do |file|
        check_open_file_test_file_content(file)
      end
    end
  end
end
