require 'spec_helper'

describe ChunkyPNG::Vector do
  subject { ChunkyPNG::Vector.new([ChunkyPNG::Point.new(2, 5), ChunkyPNG::Point.new(1, 3), ChunkyPNG::Point.new(4, 6)]) }

  it { should respond_to(:points) }

  describe '#length' do
    it "shopuld have 3 items" do
      expect(subject.length).to eql(3)
    end
  end

  describe '#x_range' do
    it "should get the right range of x values" do
      expect(subject.x_range).to eql(1..4)
    end

    it "should find the minimum x-coordinate" do
      expect(subject.min_x).to eql(1)
    end

    it "should find the maximum x-coordinate" do
      expect(subject.max_x).to eql(4)
    end

    it "should calculate the width correctly" do
      expect(subject.width).to eql(4)
    end
  end

  describe '#y_range' do
    it "should get the right range of y values" do
      expect(subject.y_range).to eql(3..6)
    end

    it "should find the minimum x-coordinate" do
      expect(subject.min_y).to eql(3)
    end

    it "should find the maximum x-coordinate" do
      expect(subject.max_y).to eql(6)
    end

    it "should calculate the height correctly" do
      expect(subject.height).to eql(4)
    end
  end

  describe '#offset' do
    it "should return a ChunkyPNG::Point" do
      expect(subject.offset).to be_kind_of(ChunkyPNG::Point)
    end

    it "should use the mininum x and y coordinates as values for the point" do
      expect(subject.offset.x).to eql subject.min_x
      expect(subject.offset.y).to eql subject.min_y
    end
  end

  describe '#dimension' do
    it "should return a ChunkyPNG::Dimension" do
      expect(subject.dimension).to be_kind_of(ChunkyPNG::Dimension)
    end

    it "should use the width and height of the vector for the dimension" do
      expect(subject.dimension.width).to eql subject.width
      expect(subject.dimension.height).to eql subject.height
    end
  end

  describe '#edges' do
    it "should get three edges when closing the path" do
      expect(subject.edges(true).to_a).to eql [[ChunkyPNG::Point.new(2, 5), ChunkyPNG::Point.new(1, 3)],
                                          [ChunkyPNG::Point.new(1, 3), ChunkyPNG::Point.new(4, 6)],
                                          [ChunkyPNG::Point.new(4, 6), ChunkyPNG::Point.new(2, 5)]]
    end

    it "should get two edges when not closing the path" do
      expect(subject.edges(false).to_a).to eql [[ChunkyPNG::Point.new(2, 5), ChunkyPNG::Point.new(1, 3)],
                                           [ChunkyPNG::Point.new(1, 3), ChunkyPNG::Point.new(4, 6)]]
    end
  end
end

describe 'ChunkyPNG.Vector' do
  let(:example) { ChunkyPNG::Vector.new([ChunkyPNG::Point.new(2, 4), ChunkyPNG::Point.new(1, 2), ChunkyPNG::Point.new(3, 6)]) }

  it "should return an empty vector when given an empty array" do
    expect(ChunkyPNG::Vector()).to eql ChunkyPNG::Vector.new([])
    expect(ChunkyPNG::Vector(*[])).to eql ChunkyPNG::Vector.new([])
  end

  it "should raise an error when an odd number of numerics is given" do
    expect { ChunkyPNG::Vector(1, 2, 3) }.to raise_error(ArgumentError)
  end

  it "should create a vector from a string" do
    expect(ChunkyPNG::Vector('(2,4) (1,2) (3,6)')).to eql example
  end

  it "should create a vector from a flat array" do
    expect(ChunkyPNG::Vector(2,4,1,2,3,6)).to eql example
  end

  it "should create a vector from a nested array" do
    expect(ChunkyPNG::Vector('(2,4)', [1, 2], :x => 3, :y => 6)).to eql example
  end
end
