# encoding: ascii-8bit
require 'spec_helper'

require 'stringio'
if defined?(Encoding)
  Encoding.default_external = 'ASCII-8BIT'
end

describe Packer do
  let :packer do
    Packer.new
  end

  it 'initialize' do
    Packer.new
    Packer.new(nil)
    Packer.new(StringIO.new)
    Packer.new({})
    Packer.new(StringIO.new, {})
  end

  it 'buffer' do
    o1 = packer.buffer.object_id
    packer.buffer << 'frsyuki'
    packer.buffer.to_s.should == 'frsyuki'
    packer.buffer.object_id.should == o1
  end
end

