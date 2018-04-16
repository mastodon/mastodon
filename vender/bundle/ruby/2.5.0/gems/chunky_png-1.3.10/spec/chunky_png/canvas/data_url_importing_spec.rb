require 'spec_helper'

describe ChunkyPNG::Canvas do

  describe '.from_data_url' do
    it "should import an image from a data URL" do
      data_url = reference_canvas('operations').to_data_url
      expect(ChunkyPNG::Canvas.from_data_url(data_url)).to eql reference_canvas('operations')
    end

    it "should raise an exception if the string is not a proper data URL" do
      expect { ChunkyPNG::Canvas.from_data_url('whatever') }.to raise_error(ChunkyPNG::SignatureMismatch)
    end
  end
end
