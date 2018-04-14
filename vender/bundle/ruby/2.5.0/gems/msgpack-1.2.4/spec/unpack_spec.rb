# encoding: ascii-8bit
require 'spec_helper'

require 'stringio'
if defined?(Encoding)
  Encoding.default_external = 'ASCII-8BIT'
end

describe MessagePack do
  it 'MessagePack.unpack symbolize_keys' do
    symbolized_hash = {:a => 'b', :c => 'd'}
    MessagePack.load(MessagePack.pack(symbolized_hash), :symbolize_keys => true).should == symbolized_hash
    MessagePack.unpack(MessagePack.pack(symbolized_hash), :symbolize_keys => true).should == symbolized_hash
  end

  it 'Unpacker#read symbolize_keys' do
    unpacker = MessagePack::Unpacker.new(:symbolize_keys => true)
    symbolized_hash = {:a => 'b', :c => 'd'}
    unpacker.feed(MessagePack.pack(symbolized_hash)).read.should == symbolized_hash
  end

  it "msgpack str 8 type" do
    MessagePack.unpack([0xd9, 0x00].pack('C*')).should == ""
    MessagePack.unpack([0xd9, 0x01].pack('C*') + 'a').should == "a"
    MessagePack.unpack([0xd9, 0x02].pack('C*') + 'aa').should == "aa"
  end

  it "msgpack str 16 type" do
    MessagePack.unpack([0xda, 0x00, 0x00].pack('C*')).should == ""
    MessagePack.unpack([0xda, 0x00, 0x01].pack('C*') + 'a').should == "a"
    MessagePack.unpack([0xda, 0x00, 0x02].pack('C*') + 'aa').should == "aa"
  end

  it "msgpack str 32 type" do
    MessagePack.unpack([0xdb, 0x00, 0x00, 0x00, 0x00].pack('C*')).should == ""
    MessagePack.unpack([0xdb, 0x00, 0x00, 0x00, 0x01].pack('C*') + 'a').should == "a"
    MessagePack.unpack([0xdb, 0x00, 0x00, 0x00, 0x02].pack('C*') + 'aa').should == "aa"
  end

  it "msgpack bin 8 type" do
    MessagePack.unpack([0xc4, 0x00].pack('C*')).should == ""
    MessagePack.unpack([0xc4, 0x01].pack('C*') + 'a').should == "a"
    MessagePack.unpack([0xc4, 0x02].pack('C*') + 'aa').should == "aa"
  end

  it "msgpack bin 16 type" do
    MessagePack.unpack([0xc5, 0x00, 0x00].pack('C*')).should == ""
    MessagePack.unpack([0xc5, 0x00, 0x01].pack('C*') + 'a').should == "a"
    MessagePack.unpack([0xc5, 0x00, 0x02].pack('C*') + 'aa').should == "aa"
  end

  it "msgpack bin 32 type" do
    MessagePack.unpack([0xc6, 0x00, 0x00, 0x00, 0x00].pack('C*')).should == ""
    MessagePack.unpack([0xc6, 0x00, 0x00, 0x00, 0x01].pack('C*') + 'a').should == "a"
    MessagePack.unpack([0xc6, 0x00, 0x00, 0x00, 0x02].pack('C*') + 'aa').should == "aa"
  end
end
