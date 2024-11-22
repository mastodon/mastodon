# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmojiFormatter do
  let!(:emoji) { Fabricate(:custom_emoji, shortcode: 'coolcat') }

  def preformat_text(str)
    TextFormatter.new(str).to_s
  end

  describe '#to_s' do
    subject { described_class.new(text, emojis).to_s }

    let(:emojis) { [emoji] }

    context 'when given text that is not marked as html-safe' do
      let(:text) { 'Foo' }

      it 'raises an argument error' do
        expect { subject }.to raise_error ArgumentError
      end
    end

    context 'when given text with an emoji shortcode at the start' do
      let(:text) { preformat_text(':coolcat: Beep boop') }

      it 'converts the shortcode to an image tag' do
        expect(subject).to match(/<img rel="emoji" draggable="false" width="16" height="16" class="emojione custom-emoji" alt=":coolcat:"/)
      end
    end

    context 'when given text with an emoji shortcode in the middle' do
      let(:text) { preformat_text('Beep :coolcat: boop') }

      it 'converts the shortcode to an image tag' do
        expect(subject).to match(/Beep <img rel="emoji" draggable="false" width="16" height="16" class="emojione custom-emoji" alt=":coolcat:"/)
      end
    end

    context 'when given text with concatenated emoji shortcodes' do
      let(:text) { preformat_text(':coolcat::coolcat:') }

      it 'does not touch the shortcodes' do
        expect(subject).to match(/:coolcat::coolcat:/)
      end
    end

    context 'when given text with an emoji shortcode at the end' do
      let(:text) { preformat_text('Beep boop :coolcat:') }

      it 'converts the shortcode to an image tag' do
        expect(subject).to match(/boop <img rel="emoji" draggable="false" width="16" height="16" class="emojione custom-emoji" alt=":coolcat:"/)
      end
    end
  end
end
