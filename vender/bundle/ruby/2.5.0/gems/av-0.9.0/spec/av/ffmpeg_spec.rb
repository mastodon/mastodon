require 'spec_helper'

describe Av::Commands::Ffmpeg do
  let(:subject) { Av::Commands::Ffmpeg.new }
  let(:list) { ['one', 'two'] }
  
  describe '.filter_concat' do
    before do
      subject.filter_concat(list)
    end
    
    it { expect(subject.input_params.to_s).to include %Q(concat -i) }
  end

  describe '.filter_volume' do
    before do
      subject.filter_volume('0.5')
    end
    
    it { expect(subject.input_params.to_s).to eq "-af volume=0.5" }
  end
end