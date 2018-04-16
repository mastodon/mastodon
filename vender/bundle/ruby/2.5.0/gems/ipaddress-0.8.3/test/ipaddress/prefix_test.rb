require 'test_helper'
 
class Prefix32Test < Minitest::Test

  def setup
    @netmask0  = "0.0.0.0"
    @netmask8  = "255.0.0.0"
    @netmask16 = "255.255.0.0"
    @netmask24 = "255.255.255.0"
    @netmask30 = "255.255.255.252"
    @netmasks  = [@netmask0,@netmask8,@netmask16,@netmask24,@netmask30]
    
    @prefix_hash = {
      "0.0.0.0"         => 0,
      "255.0.0.0"       => 8,
      "255.255.0.0"     => 16,
      "255.255.255.0"   => 24,
      "255.255.255.252" => 30}

    @octets_hash = {
      [0,0,0,0]         => 0,
      [255,0,0,0]       => 8,
      [255,255,0,0]     => 16,
      [255,255,255,0]   => 24,
      [255,255,255,252] => 30}

    @u32_hash = {
      0  => 0,
      8  => 4278190080,
      16 => 4294901760,
      24 => 4294967040,
      30 => 4294967292}
    
    @klass = IPAddress::Prefix32
  end

  def test_attributes
    @prefix_hash.values.each do |num|
      prefix = @klass.new(num)
      assert_equal num, prefix.prefix
    end
  end

  def test_parse_netmask
    @prefix_hash.each do |netmask, num|
      prefix = @klass.parse_netmask(netmask)
      assert_equal num, prefix.prefix
      assert_instance_of @klass, prefix
    end
  end

  def test_method_to_ip
    @prefix_hash.each do |netmask, num|
      prefix = @klass.new(num)
      assert_equal netmask, prefix.to_ip
    end
  end
  
  def test_method_to_s
    prefix = @klass.new(8)
    assert_equal "8", prefix.to_s
  end
  
  def test_method_bits
    prefix = @klass.new(16)
    str = "1"*16 + "0"*16
    assert_equal str, prefix.bits
  end

  def test_method_to_u32
    @u32_hash.each do |num,u32|
      assert_equal u32, @klass.new(num).to_u32
    end
  end

  def test_method_plus
    p1 = @klass.new 8
    p2 = @klass.new 10
    assert_equal 18, p1+p2
    assert_equal 12, p1+4
  end

  def test_method_minus
    p1 = @klass.new 8
    p2 = @klass.new 24
    assert_equal 16, p1-p2
    assert_equal 16, p2-p1
    assert_equal 20, p2-4
  end

  def test_initialize
    assert_raises (ArgumentError) do
      @klass.new 33
    end
    assert_instance_of @klass, @klass.new(8)
  end

  def test_method_octets
    @octets_hash.each do |arr,pref|
      prefix = @klass.new(pref)
      assert_equal prefix.octets, arr
    end
  end

  def test_method_brackets
    @octets_hash.each do |arr,pref|
      prefix = @klass.new(pref)
      arr.each_with_index do |oct,index|
        assert_equal prefix[index], oct
      end
    end
  end

  def test_method_hostmask
    prefix = @klass.new(8)
    assert_equal "0.255.255.255", prefix.hostmask
  end
    
end # class Prefix32Test

  
class Prefix128Test < Minitest::Test
  
  def setup
    @u128_hash = {
      32  => 340282366841710300949110269838224261120,
      64 => 340282366920938463444927863358058659840,
      96 => 340282366920938463463374607427473244160,
      126 => 340282366920938463463374607431768211452}
    
    @klass = IPAddress::Prefix128
  end

  def test_initialize
    assert_raises (ArgumentError) do
      @klass.new 129
    end
    assert_instance_of @klass, @klass.new(64)
  end

  def test_method_bits
    prefix = @klass.new(64)
    str = "1"*64 + "0"*64
    assert_equal str, prefix.bits
  end

  def test_method_to_u32
    @u128_hash.each do |num,u128|
      assert_equal u128, @klass.new(num).to_u128
    end
  end

end # class Prefix128Test
