require 'rails_helper'

RSpec.describe Emoji do
  describe '#unicode' do
    it 'returns a unicode for a shortcode' do
      expect(Emoji.instance.unicode(':joy:')).to eq '😂'
    end
  end

  describe '#names' do
    it 'returns an array' do
      expect(Emoji.instance.names).to be_an Array
    end
  end
end
