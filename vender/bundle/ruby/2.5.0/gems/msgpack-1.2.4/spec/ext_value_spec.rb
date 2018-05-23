# encoding: ascii-8bit
require 'spec_helper'

describe MessagePack::ExtensionValue do
  subject do
    described_class.new(1, "data")
  end

  describe '#type/#type=' do
    it 'returns value set by #initialize' do
      subject.type.should == 1
    end

    it 'assigns a value' do
      subject.type = 2
      subject.type.should == 2
    end
  end

  describe '#payload/#payload=' do
    it 'returns value set by #initialize' do
      subject.payload.should == "data"
    end

    it 'assigns a value' do
      subject.payload = "a"
      subject.payload.should == "a"
    end
  end

  describe '#==/#eql?/#hash' do
    it 'returns equivalent if the content is same' do
      ext1 = MessagePack::ExtensionValue.new(1, "data")
      ext2 = MessagePack::ExtensionValue.new(1, "data")
      (ext1 == ext2).should be true
      ext1.eql?(ext2).should be true
      (ext1.hash == ext2.hash).should be true
    end

    it 'returns not equivalent if type is not same' do
      ext1 = MessagePack::ExtensionValue.new(1, "data")
      ext2 = MessagePack::ExtensionValue.new(2, "data")
      (ext1 == ext2).should be false
      ext1.eql?(ext2).should be false
      (ext1.hash == ext2.hash).should be false
    end

    it 'returns not equivalent if payload is not same' do
      ext1 = MessagePack::ExtensionValue.new(1, "data")
      ext2 = MessagePack::ExtensionValue.new(1, "value")
      (ext1 == ext2).should be false
      ext1.eql?(ext2).should be false
      (ext1.hash == ext2.hash).should be false
    end
  end

  describe '#to_msgpack' do
    it 'serializes very short payload' do
      ext = MessagePack::ExtensionValue.new(1, "a"*2).to_msgpack
      ext.should == "\xd5\x01" + "a"*2
    end

    it 'serializes short payload' do
      ext = MessagePack::ExtensionValue.new(1, "a"*18).to_msgpack
      ext.should == "\xc7\x12\x01" + "a"*18
    end

    it 'serializes long payload' do
      ext = MessagePack::ExtensionValue.new(1, "a"*65540).to_msgpack
      ext.should == "\xc9\x00\x01\x00\x04\x01" + "a"*65540
    end

    it 'with a packer serializes to a packer' do
      ext = MessagePack::ExtensionValue.new(1, "aa")
      packer = MessagePack::Packer.new
      ext.to_msgpack(packer)
      packer.buffer.to_s.should == "\xd5\x01aa"
    end

    [-129, -65540, -(2**40), 128, 65540, 2**40].each do |type|
      context "with invalid type (#{type})" do
        it 'raises RangeError' do
          lambda { MessagePack::ExtensionValue.new(type, "a").to_msgpack }.should raise_error(RangeError)
        end
      end
    end
  end

  describe '#dup' do
    it 'duplicates' do
      ext1 = MessagePack::ExtensionValue.new(1, "data")
      ext2 = ext1.dup
      ext2.type = 2
      ext2.payload = "data2"
      ext1.type.should == 1
      ext1.payload.should == "data"
    end
  end
end
