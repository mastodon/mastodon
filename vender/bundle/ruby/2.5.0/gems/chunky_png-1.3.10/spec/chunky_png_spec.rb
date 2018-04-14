require 'spec_helper'

describe ChunkyPNG do
  it "should have a VERSION constant" do
    expect(ChunkyPNG.const_defined?('VERSION')).to eql true
  end
end
