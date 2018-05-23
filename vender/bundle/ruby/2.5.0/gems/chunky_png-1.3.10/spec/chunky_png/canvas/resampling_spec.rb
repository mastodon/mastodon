require 'spec_helper'

describe ChunkyPNG::Canvas::Resampling do

  subject { reference_canvas('clock') }

  describe '#resample_nearest_neighbor' do

    it "should downscale from 2x2 to 1x1 correctly" do
      canvas = ChunkyPNG::Canvas.new(2, 2, [1, 2, 3, 4])
      expect(canvas.resample_nearest_neighbor(1, 1)).to eql ChunkyPNG::Canvas.new(1, 1, [4])
    end

    it "should upscale from 2x2 to 4x4 correctly" do
      canvas = ChunkyPNG::Canvas.new(2, 2, [1, 2, 3, 4])
      expect(canvas.resample_nearest_neighbor(4, 4)).to eql ChunkyPNG::Canvas.new(4, 4, [1, 1, 2, 2, 1, 1, 2, 2, 3, 3, 4, 4, 3, 3, 4, 4])
    end

    it "should upscale both axis of the image" do
      expect(subject.resample_nearest_neighbor(45, 45)).to eql reference_canvas('clock_nn_xup_yup')
    end

    it "should downscale both axis of the image" do
      expect(subject.resample_nearest_neighbor(12, 12)).to eql reference_canvas('clock_nn_xdown_ydown')
    end

    it "should downscale the x-axis and upscale the y-axis of the image" do
      expect(subject.resample_nearest_neighbor(20, 50)).to eql reference_canvas('clock_nn_xdown_yup')
    end

    it "should not return itself" do
      subject.resample_nearest_neighbor(1, 1).should_not equal(subject)
    end

    it "should not change the original image's dimensions" do
      expect { subject.resample_nearest_neighbor(1, 1) }.to_not change { subject.dimension }
    end
  end

  describe '#resample_nearest_neighbor!' do
    it "should upscale both axis of the image" do
      subject.resample_nearest_neighbor!(45, 45)
      expect(subject).to eql reference_canvas('clock_nn_xup_yup')
    end

    it "should downscale both axis of the image" do
      subject.resample_nearest_neighbor!(12, 12)
      expect(subject).to eql reference_canvas('clock_nn_xdown_ydown')
    end

    it "should downscale the x-axis and upscale the y-axis of the image" do
      subject.resample_nearest_neighbor!(20, 50)
      expect(subject).to eql reference_canvas('clock_nn_xdown_yup')
    end

    it "should return itself" do
      expect(subject.resample_nearest_neighbor!(1, 1)).to equal(subject)
    end

    it "should change the original image's dimensions" do
      expect { subject.resample_nearest_neighbor!(1, 1) }.to change { subject.dimension }.to(ChunkyPNG::Dimension('1x1'))
    end
  end

  describe "#resample_bilinear" do
    it "should downscale from 2x2 to 1x1 correctly" do
      canvas = ChunkyPNG::Canvas.new(2, 2, [1, 2, 3, 4])
      expect(canvas.resample_bilinear(1, 1)).to eql ChunkyPNG::Canvas.new(1, 1, [2])
    end

    it "should upscale from 2x2 to 4x4 correctly" do
      canvas = ChunkyPNG::Canvas.new(2, 2, [1, 2, 3, 4])
      expect(canvas.resample_bilinear(4, 4)).to eql ChunkyPNG::Canvas.new(4, 4, [1, 2, 1, 2, 2, 2, 2, 2, 2, 3, 3, 4, 3, 3, 4, 4])
    end

    it "should upscale both axis of the image" do
      expect(subject.resample_bilinear(45, 45)).to eql reference_canvas('clock_bl_xup_yup')
    end

    it "should downscale both axis of the image" do
      expect(subject.resample_bilinear(12, 12)).to eql reference_canvas('clock_bl_xdown_ydown')
    end

    it "should downscale the x-axis and upscale the y-axis of the image" do
      expect(subject.resample_bilinear(20, 50)).to eql reference_canvas('clock_bl_xdown_yup')
    end

    it "should not return itself" do
      subject.resample_bilinear(1, 1).should_not equal(subject)
    end

    it "should not change the original image's dimensions" do
      expect { subject.resample_bilinear(1, 1) }.to_not change { subject.dimension }
    end
  end

  describe '#resample_bilinear!' do
    it "should upscale both axis of the image" do
      subject.resample_bilinear!(45, 45)
      expect(subject).to eql reference_canvas('clock_bl_xup_yup')
    end

    it "should downscale both axis of the image" do
      subject.resample_bilinear!(12, 12)
      expect(subject).to eql reference_canvas('clock_bl_xdown_ydown')
    end

    it "should downscale the x-axis and upscale the y-axis of the image" do
      subject.resample_bilinear!(20, 50)
      expect(subject).to eql reference_canvas('clock_bl_xdown_yup')
    end

    it "should return itself" do
      expect(subject.resample_bilinear!(1, 1)).to equal(subject)
    end

    it "should change the original image's dimensions" do
      expect { subject.resample_bilinear!(1, 1) }.to change { subject.dimension }.to(ChunkyPNG::Dimension('1x1'))
    end
  end
end
