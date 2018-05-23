require 'spec_helper'

describe Av::Commands::Avconv do
  let(:subject) { Av::Commands::Avconv.new }
  let(:list) { ['one', 'two'] }
  
  describe '.filter_concat' do
    before do
      subject.filter_concat(list)
    end
    
    it { expect(subject.input_params.to_s).to include %Q(concat:one\\|two) }
  end

  describe '.filter_volume' do
    before do
      subject.filter_volume('0.5')
    end
    
    it { expect(subject.input_params.to_s).to eq "-af volume=volume=0.5" }
  end
end

