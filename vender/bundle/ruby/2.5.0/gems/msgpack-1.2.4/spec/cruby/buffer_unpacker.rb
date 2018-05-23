# encoding: ascii-8bit
require 'spec_helper'

describe Unpacker do
  let :unpacker do
    Unpacker.new
  end

  let :packer do
    Packer.new
  end

  it 'buffer' do
    o1 = unpacker.buffer.object_id
    unpacker.buffer << 'frsyuki'
    unpacker.buffer.to_s.should == 'frsyuki'
    unpacker.buffer.object_id.should == o1
  end
end
