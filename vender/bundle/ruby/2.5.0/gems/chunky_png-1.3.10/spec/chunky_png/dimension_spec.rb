require 'spec_helper'

describe ChunkyPNG::Dimension do
  subject { ChunkyPNG::Dimension.new(2, 3) }

  it { should respond_to(:width) }
  it { should respond_to(:height) }

  describe '#area' do
    it "should calculate the area correctly" do
      expect(subject.area).to eql 6
    end
  end
end

describe 'ChunkyPNG.Dimension' do
  subject { ChunkyPNG::Dimension.new(1, 2) }

  it "should create a dimension from a 2-item array" do
    expect(ChunkyPNG::Dimension([1, 2])).to     eql subject
    expect(ChunkyPNG::Dimension(['1', '2'])).to eql subject
  end

  it "should create a dimension from a hash with x and y keys" do
    expect(ChunkyPNG::Dimension(:width => 1, :height => 2)).to       eql subject
    expect(ChunkyPNG::Dimension('width' => '1', 'height' => '2')).to eql subject
  end

  it "should create a dimension from a point-like string" do
    [
      ChunkyPNG::Dimension('1,2'),
      ChunkyPNG::Dimension('1   2'),
      ChunkyPNG::Dimension('(1 , 2)'),
      ChunkyPNG::Dimension("{1x2}"),
      ChunkyPNG::Dimension("[1\t2}"),
    ].all? { |point| point == subject }
  end

  it "should create a dimension from an object that responds to width and height" do
    mock_object = Struct.new(:width, :height).new(1, 2)
    expect(ChunkyPNG::Dimension(mock_object)).to eql subject
  end

  it "should raise an exception if the input is not understood" do
    expect { ChunkyPNG::Dimension(Object.new) }.to raise_error(ArgumentError)
    expect { ChunkyPNG::Dimension(1, 2, 3) }.to raise_error(ArgumentError)
  end
end
