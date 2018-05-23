require 'spec_helper'

describe ChunkyPNG::Canvas::Operations do

  subject { reference_canvas('operations') }

  describe '#grayscale' do
    it "should not return itself" do
      subject.grayscale.should_not equal(subject)
    end

    it "should convert the image correctly" do
      expect(subject.grayscale).to eql reference_canvas('operations_grayscale')
    end

    it "should not adjust the current image" do
      expect { subject.grayscale }.to_not change { subject.pixels }
    end
  end

  describe '#grayscale!' do
    it "should return itself" do
      expect(subject.grayscale!).to equal(subject)
    end

    it "should convert the image correctly" do
      subject.grayscale!
      expect(subject).to eql reference_canvas('operations_grayscale')
    end
  end

  describe '#crop' do
    it "should crop the right pixels from the original canvas" do
      expect(subject.crop(10, 5, 4, 8)).to eql reference_canvas('cropped')
    end

    it "should not return itself" do
      subject.crop(10, 5, 4, 8).should_not equal(subject)
    end

    it "should not adjust the current image" do
      expect { subject.crop(10, 5, 4, 8) }.to_not change { subject.pixels }
    end

    it "should raise an exception when the cropped image falls outside the oiginal image" do
      expect { subject.crop(16, 16, 2, 2) }.to raise_error(ChunkyPNG::OutOfBounds)
    end
  end

  describe '#crop!' do
    context 'when cropping both width and height' do
      let(:crop_opts) { [10, 5, 4, 8] }

      it "should crop the right pixels from the original canvas" do
        subject.crop!(*crop_opts)
        expect(subject).to eql reference_canvas('cropped')
      end

      it "should have a new width and height" do
        expect { subject.crop!(*crop_opts) }.to change { subject.dimension }.
            from(ChunkyPNG::Dimension('16x16')).to(ChunkyPNG::Dimension('4x8'))
      end

      it "should return itself" do
        expect(subject.crop!(*crop_opts)).to equal(subject)
      end
    end

    context "when cropping just the height" do
      let(:crop_opts) { [0, 5, 16, 8] }

      it "should crop the right pixels from the original canvas" do
        subject.crop!(*crop_opts)
        expect(subject).to eql reference_canvas('cropped_height')
      end

      it "should have a new width and height" do
        expect { subject.crop!(*crop_opts) }.to change { subject.dimension }.
            from(ChunkyPNG::Dimension('16x16')).to(ChunkyPNG::Dimension('16x8'))
      end

      it "should return itself" do
        expect(subject.crop!(*crop_opts)).to equal(subject)
      end
    end

    context "when the cropped image falls outside the original image" do
      it "should raise an exception" do
        expect { subject.crop!(16, 16, 2, 2) }.to raise_error(ChunkyPNG::OutOfBounds)
      end
    end
  end

  describe '#compose' do
    it "should compose pixels correctly" do
      subcanvas = ChunkyPNG::Canvas.new(4, 8, ChunkyPNG::Color.rgba(0, 0, 0, 75))
      expect(subject.compose(subcanvas, 8, 4)).to eql reference_canvas('composited')
    end

    it "should leave the original intact" do
      subject.compose(ChunkyPNG::Canvas.new(1,1))
      expect(subject).to eql reference_canvas('operations')
    end

    it "should not return itself" do
      subject.compose(ChunkyPNG::Canvas.new(1,1)).should_not equal(subject)
    end

    it "should raise an exception when the pixels to compose fall outside the image" do
      expect { subject.compose(ChunkyPNG::Canvas.new(1,1), 16, 16) }.to raise_error(ChunkyPNG::OutOfBounds)
    end
  end

  describe '#compose!' do
    it "should compose pixels correctly" do
      subcanvas = ChunkyPNG::Canvas.new(4, 8, ChunkyPNG::Color.rgba(0, 0, 0, 75))
      subject.compose!(subcanvas, 8, 4)
      expect(subject).to eql reference_canvas('composited')
    end

    it "should return itself" do
      expect(subject.compose!(ChunkyPNG::Canvas.new(1,1))).to equal(subject)
    end

    it "should compose a base image and mask correctly" do
      base = reference_canvas('clock_base')
      mask = reference_canvas('clock_mask_updated')
      base.compose!(mask)
      expect(base).to eql reference_canvas('clock_updated')
    end

    it "should raise an exception when the pixels to compose fall outside the image" do
      expect { subject.compose!(ChunkyPNG::Canvas.new(1,1), 16, 16) }.to raise_error(ChunkyPNG::OutOfBounds)
    end
  end

  describe '#replace' do
    it "should replace the correct pixels" do
      subcanvas = ChunkyPNG::Canvas.new(3, 2, ChunkyPNG::Color.rgb(200, 255, 0))
      expect(subject.replace(subcanvas, 5, 4)).to eql reference_canvas('replaced')
    end

    it "should not return itself" do
      subject.replace(ChunkyPNG::Canvas.new(1,1)).should_not equal(subject)
    end

    it "should leave the original intact" do
      subject.replace(ChunkyPNG::Canvas.new(1,1))
      expect(subject).to eql reference_canvas('operations')
    end

    it "should raise an exception when the pixels to replace fall outside the image" do
      expect { subject.replace(ChunkyPNG::Canvas.new(1,1), 16, 16) }.to raise_error(ChunkyPNG::OutOfBounds)
    end
  end

  describe '#replace!' do
    it "should replace the correct pixels" do
      subcanvas = ChunkyPNG::Canvas.new(3, 2, ChunkyPNG::Color.rgb(200, 255, 0))
      subject.replace!(subcanvas, 5, 4)
      expect(subject).to eql reference_canvas('replaced')
    end

    it "should return itself" do
      expect(subject.replace!(ChunkyPNG::Canvas.new(1,1))).to equal(subject)
    end

    it "should raise an exception when the pixels to replace fall outside the image" do
      expect { subject.replace!(ChunkyPNG::Canvas.new(1,1), 16, 16) }.to raise_error(ChunkyPNG::OutOfBounds)
    end
  end
end

describe ChunkyPNG::Canvas::Operations do

  subject { ChunkyPNG::Canvas.new(2, 3, [1, 2, 3, 4, 5, 6]) }

  describe '#flip_horizontally!' do
    it "should flip the pixels horizontally in place" do
      subject.flip_horizontally!
      expect(subject).to eql ChunkyPNG::Canvas.new(2, 3, [5, 6, 3, 4, 1, 2])
    end

    it "should return itself" do
      expect(subject.flip_horizontally!).to equal(subject)
    end
  end

  describe '#flip_horizontally' do
    it "should flip the pixels horizontally" do
      expect(subject.flip_horizontally).to eql ChunkyPNG::Canvas.new(2, 3, [5, 6, 3, 4, 1, 2])
    end

    it "should not return itself" do
      subject.flip_horizontally.should_not equal(subject)
    end

    it "should return a copy of itself when applied twice" do
      expect(subject.flip_horizontally.flip_horizontally).to eql subject
    end
  end

  describe '#flip_vertically!' do
    it "should flip the pixels vertically" do
      subject.flip_vertically!
      expect(subject).to eql ChunkyPNG::Canvas.new(2, 3, [2, 1, 4, 3, 6, 5])
    end

    it "should return itself" do
      expect(subject.flip_horizontally!).to equal(subject)
    end
  end

  describe '#flip_vertically' do
    it "should flip the pixels vertically" do
      expect(subject.flip_vertically).to eql ChunkyPNG::Canvas.new(2, 3, [2, 1, 4, 3, 6, 5])
    end

    it "should not return itself" do
      subject.flip_horizontally.should_not equal(subject)
    end

    it "should return a copy of itself when applied twice" do
      expect(subject.flip_vertically.flip_vertically).to eql subject
    end
  end

  describe '#rotate_left' do
    it "should rotate the pixels 90 degrees counter-clockwise" do
      expect(subject.rotate_left).to eql ChunkyPNG::Canvas.new(3, 2, [2, 4, 6, 1, 3, 5] )
    end

    it "should not return itself" do
      subject.rotate_left.should_not equal(subject)
    end

    it "should not change the image dimensions" do
      expect { subject.rotate_left }.to_not change { subject.dimension }
    end

    it "it should rotate 180 degrees when applied twice" do
      expect(subject.rotate_left.rotate_left).to eql subject.rotate_180
    end

    it "it should rotate right when applied three times" do
      expect(subject.rotate_left.rotate_left.rotate_left).to eql subject.rotate_right
    end

    it "should return itself when applied four times" do
      expect(subject.rotate_left.rotate_left.rotate_left.rotate_left).to eql subject
    end
  end

  describe '#rotate_left!' do
    it "should rotate the pixels 90 degrees clockwise" do
      subject.rotate_left!
      expect(subject).to eql ChunkyPNG::Canvas.new(3, 2, [2, 4, 6, 1, 3, 5] )
    end

    it "should return itself" do
      expect(subject.rotate_left!).to equal(subject)
    end

    it "should change the image dimensions" do
      expect { subject.rotate_left! }.to change { subject.dimension }.
          from(ChunkyPNG::Dimension('2x3')).to(ChunkyPNG::Dimension('3x2'))
    end
  end

  describe '#rotate_right' do
    it "should rotate the pixels 90 degrees clockwise" do
      expect(subject.rotate_right).to eql ChunkyPNG::Canvas.new(3, 2, [5, 3, 1, 6, 4, 2] )
    end

    it "should not return itself" do
      subject.rotate_right.should_not equal(subject)
    end

    it "should not change the image dimensions" do
      expect { subject.rotate_right }.to_not change { subject.dimension }
    end

    it "it should rotate 180 degrees when applied twice" do
      expect(subject.rotate_right.rotate_right).to eql subject.rotate_180
    end

    it "it should rotate left when applied three times" do
      expect(subject.rotate_right.rotate_right.rotate_right).to eql subject.rotate_left
    end

    it "should return itself when applied four times" do
      expect(subject.rotate_right.rotate_right.rotate_right.rotate_right).to eql subject
    end
  end

  describe '#rotate_right!' do
    it "should rotate the pixels 90 degrees clockwise" do
      subject.rotate_right!
      expect(subject).to eql ChunkyPNG::Canvas.new(3, 2, [5, 3, 1, 6, 4, 2] )
    end

    it "should return itself" do
      expect(subject.rotate_right!).to equal(subject)
    end

    it "should change the image dimensions" do
      expect { subject.rotate_right! }.to change { subject.dimension }.
          from(ChunkyPNG::Dimension('2x3')).to(ChunkyPNG::Dimension('3x2'))
    end
  end

  describe '#rotate_180' do
    it "should rotate the pixels 180 degrees" do
      expect(subject.rotate_180).to eql ChunkyPNG::Canvas.new(2, 3, [6, 5, 4, 3, 2, 1])
    end

    it "should return not itself" do
      subject.rotate_180.should_not equal(subject)
    end

    it "should return a copy of itself when applied twice" do
      expect(subject.rotate_180.rotate_180).to eql subject
    end
  end

  describe '#rotate_180!' do
    it "should rotate the pixels 180 degrees" do
      subject.rotate_180!
      expect(subject).to eql ChunkyPNG::Canvas.new(2, 3, [6, 5, 4, 3, 2, 1])
    end

    it "should return itself" do
      expect(subject.rotate_180!).to equal(subject)
    end
  end
end

describe ChunkyPNG::Canvas::Operations do

  subject { ChunkyPNG::Canvas.new(4, 4).rect(1, 1, 2, 2, 255, 255) }

  describe "#trim" do
    it "should trim the border" do
      expect(subject.trim).to eql ChunkyPNG::Canvas.new(2, 2, 255)
    end

    it "should not return itself" do
      subject.trim.should_not equal(subject)
    end

    it "should be able to fail to trim a specified color" do
      expect { subject.trim(ChunkyPNG::Color::BLACK) }.to_not change { subject.pixels }
    end

    it "should be the same after trimming an added border" do
      expect(subject.border(2).trim).to eql subject
    end
  end

  describe "#trim!" do
    it "should trim the border" do
      subject.trim!
      expect(subject).to eql ChunkyPNG::Canvas.new(2, 2, 255)
    end

    it "should return itself" do
      expect(subject.trim!).to equal(subject)
    end

    it "should change the image dimensions" do
      expect { subject.trim! }.to change { subject.dimension }.
          from(ChunkyPNG::Dimension('4x4')).to(ChunkyPNG::Dimension('2x2'))
    end
  end
end

describe ChunkyPNG::Canvas::Operations do

  subject { ChunkyPNG::Canvas.new(4, 4) }

  describe "#border" do
    it "should add the border" do
      expect(subject.border(2)).to eql reference_canvas('operations_border')
    end

    it "should not return itself" do
      subject.border(1).should_not equal(subject)
    end

    it "should retain transparency" do
      expect(ChunkyPNG::Canvas.new(1, 1).border(1).pixels).to include(0)
    end
  end

  describe "#border!" do
    it "should add the border" do
      subject.border!(2)
      expect(subject).to eql reference_canvas('operations_border')
    end

    it "should return itself" do
      expect(subject.border!(1)).to equal(subject)
    end

    it "should retain transparency" do
      subject.border!(1)
      expect(subject.pixels).to include(0)
    end

    it "should change the image dimensions" do
      expect { subject.border!(1) }.to change { subject.dimension }.
          from(ChunkyPNG::Dimension('4x4')).to(ChunkyPNG::Dimension('6x6'))
    end
  end
end
