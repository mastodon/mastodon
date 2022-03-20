require 'rails_helper'

RSpec.describe EmojiFormatter do
  let!(:emoji) { Fabricate(:custom_emoji, shortcode: 'coolcat') }

  def preformat_text(str)
    TextFormatter.new(str).to_s
  end

  describe '#to_s' do
    subject { described_class.new(text, emojis).to_s }

    let(:emojis) { [emoji] }

    context 'given a post with an emoji shortcode at the start' do
      let(:text) { preformat_text(':coolcat: Beep boop') }

      it 'converts the shortcode to an image tag' do
        is_expected.to match(/<img draggable="false" class="emojione custom-emoji" alt=":coolcat:"/)
      end
    end

    context 'given a post with an emoji shortcode in the middle' do
      let(:text) { preformat_text('Beep :coolcat: boop') }

      it 'converts the shortcode to an image tag' do
        is_expected.to match(/Beep <img draggable="false" class="emojione custom-emoji" alt=":coolcat:"/)
      end
    end

    context 'given a post with concatenated emoji shortcodes' do
      let(:text) { preformat_text(':coolcat::coolcat:') }

      it 'does not touch the shortcodes' do
        is_expected.to match(/:coolcat::coolcat:/)
      end
    end

    context 'given a post with an emoji shortcode at the end' do
      let(:text) { preformat_text('Beep boop :coolcat:') }

      it 'converts the shortcode to an image tag' do
        is_expected.to match(/boop <img draggable="false" class="emojione custom-emoji" alt=":coolcat:"/)
      end
    end
  end
end
