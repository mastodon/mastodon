# encoding: ascii-8bit
require 'spec_helper'

describe MessagePack do
  it "nil" do
    check 1, nil
  end

  it "true" do
    check 1, true
  end

  it "false" do
    check 1, false
  end

  it "zero" do
    check 1, 0
  end

  it "positive fixnum" do
    check 1, 1
    check 1, (1 << 6)
    check 1, (1 << 7)-1
  end

  it "positive int 8" do
    check 1, -1
    check 2, (1 << 7)
    check 2, (1 << 8) - 1
  end

  it "positive int 16" do
    check 3, (1 << 8)
    check 3, (1 << 16) - 1
  end

  it "positive int 32" do
    check 5, (1 << 16)
    check 5, (1 << 32) - 1
  end

  it "positive int 64" do
    check 9, (1 << 32)
    #check 9, (1<<64)-1
  end

  it "negative fixnum" do
    check 1, -1
    check 1, -((1 << 5)-1)
    check 1, -(1 << 5)
  end

  it "negative int 8" do
    check 2, -((1 << 5)+1)
    check 2, -(1 << 7)
  end

  it "negative int 16" do
    check 3, -((1 << 7)+1)
    check 3, -(1 << 15)
  end

  it "negative int 32" do
    check 5, -((1 << 15)+1)
    check 5, -(1 << 31)
  end

  it "negative int 64" do
    check 9, -((1 << 31)+1)
    check 9, -(1 << 63)
  end

  it "double" do
    check 9, 1.0
    check 9, 0.1
    check 9, -0.1
    check 9, -1.0
  end

  it "fixraw" do
    check_raw 1, 0
    check_raw 1, (1 << 5)-1
  end

  it "raw 8" do
    check_raw 2, (1 << 5)
    check_raw 2, (1 << 8)-1
  end

  it "raw 16" do
    check_raw 3, (1 << 8)
    check_raw 3, (1 << 16)-1
  end

  it "raw 32" do
    check_raw 5, (1 << 16)
    #check_raw 5, (1 << 32)-1  # memory error
  end

  it "str encoding is UTF_8" do
    v = pack_unpack('string'.force_encoding(Encoding::UTF_8))
    v.encoding.should == Encoding::UTF_8
  end

  it "str transcode US-ASCII" do
    v = pack_unpack('string'.force_encoding(Encoding::US_ASCII))
    v.encoding.should == Encoding::UTF_8
  end

  it "str transcode UTF-16" do
    v = pack_unpack('string'.encode(Encoding::UTF_16))
    v.encoding.should == Encoding::UTF_8
    v.should == 'string'
  end

  it "str transcode EUC-JP 7bit safe" do
    v = pack_unpack('string'.force_encoding(Encoding::EUC_JP))
    v.encoding.should == Encoding::UTF_8
    v.should == 'string'
  end

  it "str transcode EUC-JP 7bit unsafe" do
    v = pack_unpack([0xa4, 0xa2].pack('C*').force_encoding(Encoding::EUC_JP))
    v.encoding.should == Encoding::UTF_8
    v.should == "\xE3\x81\x82".force_encoding('UTF-8')
  end

  it "symbol to str" do
    v = pack_unpack(:a)
    v.should == "a".force_encoding('UTF-8')
  end

  it "symbol to str with encoding" do
    a = "\xE3\x81\x82".force_encoding('UTF-8')
    v = pack_unpack(a.encode('Shift_JIS').to_sym)
    v.encoding.should == Encoding::UTF_8
    v.should == a
  end

  it "symbol to bin" do
    a = "\xE3\x81\x82".force_encoding('ASCII-8BIT')
    v = pack_unpack(a.to_sym)
    v.encoding.should == Encoding::ASCII_8BIT
    v.should == a
  end

  it "bin 8" do
    check_bin 2, (1<<8)-1
  end

  it "bin 16" do
    check_bin 3, (1<<16)-1
  end

  it "bin 32" do
    check_bin 5, (1<<16)
  end

  it "bin encoding is ASCII_8BIT" do
    pack_unpack('string'.force_encoding(Encoding::ASCII_8BIT)).encoding.should == Encoding::ASCII_8BIT
  end

  it "fixarray" do
    check_array 1, 0
    check_array 1, (1 << 4)-1
  end

  it "array 16" do
    check_array 3, (1 << 4)
    #check_array 3, (1 << 16)-1
  end

  it "array 32" do
    #check_array 5, (1 << 16)
    #check_array 5, (1 << 32)-1  # memory error
  end

  it "nil" do
    match nil, "\xc0"
  end

  it "false" do
    match false, "\xc2"
  end

  it "true" do
    match true, "\xc3"
  end

  it "0" do
    match 0, "\x00"
  end

  it "127" do
    match 127, "\x7f"
  end

  it "128" do
    match 128, "\xcc\x80"
  end

  it "256" do
    match 256, "\xcd\x01\x00"
  end

  it "-1" do
    match -1, "\xff"
  end

  it "-33" do
    match -33, "\xd0\xdf"
  end

  it "-129" do
    match -129, "\xd1\xff\x7f"
  end

  it "{1=>1}" do
    obj = {1=>1}
    match obj, "\x81\x01\x01"
  end

  it "1.0" do
    match 1.0, "\xcb\x3f\xf0\x00\x00\x00\x00\x00\x00"
  end

  it "[]" do
    match [], "\x90"
  end

  it "[0, 1, ..., 14]" do
    obj = (0..14).to_a
    match obj, "\x9f\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e"
  end

  it "[0, 1, ..., 15]" do
    obj = (0..15).to_a
    match obj, "\xdc\x00\x10\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f"
  end

  it "{}" do
    obj = {}
    match obj, "\x80"
  end

## FIXME
#  it "{0=>0, 1=>1, ..., 14=>14}" do
#    a = (0..14).to_a;
#    match Hash[*a.zip(a).flatten], "\x8f\x05\x05\x0b\x0b\x00\x00\x06\x06\x0c\x0c\x01\x01\x07\x07\x0d\x0d\x02\x02\x08\x08\x0e\x0e\x03\x03\x09\x09\x04\x04\x0a\x0a"
#  end
#
#  it "{0=>0, 1=>1, ..., 15=>15}" do
#    a = (0..15).to_a;
#    match Hash[*a.zip(a).flatten], "\xde\x00\x10\x05\x05\x0b\x0b\x00\x00\x06\x06\x0c\x0c\x01\x01\x07\x07\x0d\x0d\x02\x02\x08\x08\x0e\x0e\x03\x03\x09\x09\x0f\x0f\x04\x04\x0a\x0a"
#  end

## FIXME
#  it "fixmap" do
#    check_map 1, 0
#    check_map 1, (1<<4)-1
#  end
#
#  it "map 16" do
#    check_map 3, (1<<4)
#    check_map 3, (1<<16)-1
#  end
#
#  it "map 32" do
#    check_map 5, (1<<16)
#    #check_map 5, (1<<32)-1  # memory error
#  end

  def check(len, obj)
    raw = obj.to_msgpack.to_s
    raw.length.should == len
    MessagePack.unpack(raw).should == obj
  end

  def check_raw(overhead, num)
    check num+overhead, (" "*num).force_encoding(Encoding::UTF_8)
  end

  def check_bin(overhead, num)
    check num+overhead, (" "*num).force_encoding(Encoding::ASCII_8BIT)
  end

  def check_array(overhead, num)
    check num+overhead, Array.new(num)
  end

  def match(obj, buf)
    raw = obj.to_msgpack.to_s
    raw.should == buf
  end

  def pack_unpack(obj)
    MessagePack.unpack(obj.to_msgpack)
  end
end

