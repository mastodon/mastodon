require 'rails_helper'

RSpec.describe EmojiHelper, type: :helper do
  describe '#emojify' do
    it 'converts shortcodes to unicode' do
      text = ':book: Book'
      expect(emojify(text)).to eq '📖 Book'
    end

    it 'does not convert shortcodes that are part of a string into unicode' do
      text = ':see_no_evil::hear_no_evil::speak_no_evil:'
      expect(emojify(text)).to eq text
    end
  end
end
