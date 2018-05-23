# encoding: ascii-8bit
require 'spec_helper'

describe Unpacker do
  let :unpacker do
    Unpacker.new
  end

  let :packer do
    Packer.new
  end

  it 'skip_nil succeeds' do
    unpacker.feed("\xc0")
    unpacker.skip_nil.should == true
  end

  it 'skip_nil fails' do
    unpacker.feed("\x90")
    unpacker.skip_nil.should == false
  end

  it 'skip skips objects' do
    packer.write(1)
    packer.write(2)
    packer.write(3)
    packer.write(4)
    packer.write(5)

    unpacker = Unpacker.new
    unpacker.feed(packer.to_s)

    unpacker.read.should == 1
    unpacker.skip
    unpacker.read.should == 3
    unpacker.skip
    unpacker.read.should == 5
  end

  it 'skip raises EOFError' do
    lambda {
      unpacker.skip
    }.should raise_error(EOFError)
  end

  it 'skip_nil raises EOFError' do
    lambda {
      unpacker.skip_nil
    }.should raise_error(EOFError)
  end

  it 'skip raises level stack too deep error' do
    512.times { packer.write_array_header(1) }
    packer.write(nil)

    unpacker = Unpacker.new
    unpacker.feed(packer.to_s)
    lambda {
      unpacker.skip
    }.should raise_error(MessagePack::StackError)
  end

  it 'skip raises invalid byte error' do
    unpacker.feed("\xc1")
    lambda {
      unpacker.skip
    }.should raise_error(MessagePack::MalformedFormatError)
  end
end

