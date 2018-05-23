require 'spec_helper'

describe ChunkyPNG::Canvas do

  subject { ChunkyPNG::Canvas.new(1, 1, ChunkyPNG::Color::WHITE) }

  it { should respond_to(:width) }
  it { should respond_to(:height) }
  it { should respond_to(:pixels) }

  describe '#initialize' do
    it "should accept a single color value as background color" do
      canvas = ChunkyPNG::Canvas.new(2, 2, 'red @ 0.8')
      expect(canvas[1, 0]).to eql ChunkyPNG::Color.parse('red @ 0.8')
    end

    it "should raise an error if the color value is not understood" do
      expect { ChunkyPNG::Canvas.new(2, 2, :nonsense) }.to raise_error(ArgumentError)
    end

    it "should accept an array as initial pixel values" do
      canvas = ChunkyPNG::Canvas.new(2, 2, [1,2,3,4])
      expect(canvas[0, 0]).to eql 1
      expect(canvas[1, 0]).to eql 2
      expect(canvas[0, 1]).to eql 3
      expect(canvas[1, 1]).to eql 4
    end

    it "should raise an ArgumentError if the initial array does not have the correct number of elements" do
      expect { ChunkyPNG::Canvas.new(2, 2, [1,2,3]) }.to raise_error(ArgumentError)
      expect { ChunkyPNG::Canvas.new(2, 2, [1,2,3,4,5]) }.to raise_error(ArgumentError)
    end

    it "should use a transparent background by default" do
      canvas = ChunkyPNG::Canvas.new(1, 1)
      expect(canvas[0,0]).to eql ChunkyPNG::Color::TRANSPARENT
    end
  end

  describe '#dimension' do
    it "should return the dimensions as a Dimension instance" do
      expect(subject.dimension).to eql ChunkyPNG::Dimension('1x1')
    end
  end

  describe '#area' do
    it "should return the dimensions as two-item array" do
      expect(subject.area).to eql ChunkyPNG::Dimension('1x1').area
    end
  end

  describe '#include?' do
    it "should return true if the coordinates are within bounds, false otherwise" do
      expect(subject.include_xy?( 0,  0)).to eql true

      expect(subject.include_xy?(-1,  0)).to eql false
      expect(subject.include_xy?( 1,  0)).to eql false
      expect(subject.include_xy?( 0, -1)).to eql false
      expect(subject.include_xy?( 0,  1)).to eql false
      expect(subject.include_xy?(-1, -1)).to eql false
      expect(subject.include_xy?(-1,  1)).to eql false
      expect(subject.include_xy?( 1, -1)).to eql false
      expect(subject.include_xy?( 1,  1)).to eql false
    end

    it "should accept strings, arrays, hashes and points as well" do
      expect(subject).to     include('0, 0')
      subject.should_not include('0, 1')
      expect(subject).to     include([0, 0])
      subject.should_not include([0, 1])
      expect(subject).to     include(:y => 0, :x => 0)
      subject.should_not include(:y => 1, :x => 0)
      expect(subject).to     include(ChunkyPNG::Point.new(0, 0))
      subject.should_not include(ChunkyPNG::Point.new(0, 1))
    end
  end

  describe '#include_x?' do
    it "should return true if the x-coordinate is within bounds, false otherwise" do
      expect(subject.include_x?( 0)).to eql true
      expect(subject.include_x?(-1)).to eql false
      expect(subject.include_x?( 1)).to eql false
    end
  end

  describe '#include_y?' do
    it "should return true if the y-coordinate is within bounds, false otherwise" do
      expect(subject.include_y?( 0)).to eql true
      expect(subject.include_y?(-1)).to eql false
      expect(subject.include_y?( 1)).to eql false
    end
  end

  describe '#assert_xy!' do
    it "should not raise an exception if the coordinates are within bounds" do
      expect(subject).to receive(:include_xy?).with(0, 0).and_return(true)
      expect { subject.send(:assert_xy!, 0, 0) }.to_not raise_error
    end

    it "should raise an exception if the coordinates are out of bounds bounds" do
      expect(subject).to receive(:include_xy?).with(0, -1).and_return(false)
      expect { subject.send(:assert_xy!, 0, -1) }.to raise_error(ChunkyPNG::OutOfBounds)
    end
  end

  describe '#assert_x!' do
    it "should not raise an exception if the x-coordinate is within bounds" do
      expect(subject).to receive(:include_x?).with(0).and_return(true)
      expect { subject.send(:assert_x!, 0) }.to_not raise_error
    end

    it "should raise an exception if the x-coordinate is out of bounds bounds" do
      expect(subject).to receive(:include_y?).with(-1).and_return(false)
      expect { subject.send(:assert_y!, -1) }.to raise_error(ChunkyPNG::OutOfBounds)
    end
  end

  describe '#[]' do
    it "should return the pixel value if the coordinates are within bounds" do
      expect(subject[0, 0]).to eql ChunkyPNG::Color::WHITE
    end

    it "should assert the coordinates to be within bounds" do
      expect(subject).to receive(:assert_xy!).with(0, 0)
      subject[0, 0]
    end
  end

  describe '#get_pixel' do
    it "should return the pixel value if the coordinates are within bounds" do
      expect(subject.get_pixel(0, 0)).to eql ChunkyPNG::Color::WHITE
    end

    it "should not assert nor check the coordinates" do
      expect(subject).to_not receive(:assert_xy!)
      expect(subject).to_not receive(:include_xy?)
      subject.get_pixel(0, 0)
    end
  end

  describe '#[]=' do
    it "should change the pixel's color value" do
      expect { subject[0, 0] = ChunkyPNG::Color::BLACK }.to change { subject[0, 0] }.
        from(ChunkyPNG::Color::WHITE).to(ChunkyPNG::Color::BLACK)
    end

    it "should assert the bounds of the image" do
      expect(subject).to receive(:assert_xy!).with(0, 0)
      subject[0, 0] = ChunkyPNG::Color::BLACK
    end
  end

  describe 'set_pixel' do
    it "should change the pixel's color value" do
      expect { subject.set_pixel(0, 0, ChunkyPNG::Color::BLACK) }.to change { subject[0, 0] }.
          from(ChunkyPNG::Color::WHITE).to(ChunkyPNG::Color::BLACK)
    end

    it "should not assert or check the bounds of the image" do
      expect(subject).to_not receive(:assert_xy!)
      expect(subject).to_not receive(:include_xy?)
      subject.set_pixel(0, 0, ChunkyPNG::Color::BLACK)
    end
  end

  describe '#set_pixel_if_within_bounds' do
    it "should change the pixel's color value" do
      expect { subject.set_pixel_if_within_bounds(0, 0, ChunkyPNG::Color::BLACK) }.to change { subject[0, 0] }.
          from(ChunkyPNG::Color::WHITE).to(ChunkyPNG::Color::BLACK)
    end

    it "should not assert, but only check the coordinates" do
      expect(subject).to_not receive(:assert_xy!)
      expect(subject).to receive(:include_xy?).with(0, 0)
      subject.set_pixel_if_within_bounds(0, 0, ChunkyPNG::Color::BLACK)
    end

    it "should do nothing if the coordinates are out of bounds" do
      expect(subject.set_pixel_if_within_bounds(-1, 1, ChunkyPNG::Color::BLACK)).to be_nil
      expect(subject[0, 0]).to eql ChunkyPNG::Color::WHITE
    end
  end

  describe '#row' do
    before { @canvas = reference_canvas('operations') }

    it "should give an out of bounds exception when y-coordinate is out of bounds" do
      expect { @canvas.row(-1) }.to raise_error(ChunkyPNG::OutOfBounds)
      expect { @canvas.row(16) }.to raise_error(ChunkyPNG::OutOfBounds)
    end

    it "should return the correct pixels" do
      data = @canvas.row(0)
      expect(data.length).to eql @canvas.width
      expect(data).to eql [65535, 268500991, 536936447, 805371903, 1073807359, 1342242815, 1610678271, 1879113727, 2147549183, 2415984639, 2684420095, 2952855551, 3221291007, 3489726463, 3758161919, 4026597375]
    end
  end

  describe '#column' do
    before { @canvas = reference_canvas('operations') }

    it "should give an out of bounds exception when x-coordinate is out of bounds" do
      expect { @canvas.column(-1) }.to raise_error(ChunkyPNG::OutOfBounds)
      expect { @canvas.column(16) }.to raise_error(ChunkyPNG::OutOfBounds)
    end

    it "should return the correct pixels" do
      data = @canvas.column(0)
      expect(data.length).to eql @canvas.height
      expect(data).to eql [65535, 1114111, 2162687, 3211263, 4259839, 5308415, 6356991, 7405567, 8454143, 9502719, 10551295, 11599871, 12648447, 13697023, 14745599, 15794175]
    end
  end

  describe '#replace_canvas' do
    it "should change the dimension of the canvas" do
      expect { subject.send(:replace_canvas!, 2, 2, [1,2,3,4]) }.to change { subject.dimension }.
          from(ChunkyPNG::Dimension('1x1')).to(ChunkyPNG::Dimension('2x2'))
    end

    it "should change the pixel array" do
      expect { subject.send(:replace_canvas!, 2, 2, [1,2,3,4]) }.to change { subject.pixels }.
          from([ChunkyPNG::Color('white')]).to([1,2,3,4])
    end

    it "should return itself" do
      expect(subject.send(:replace_canvas!, 2, 2, [1,2,3,4])).to equal(subject)
    end
  end
end
