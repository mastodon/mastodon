require 'rails_helper'

RSpec.describe CustomEmoji, type: :model do
  describe '.from_text' do
    let!(:emojo) { Fabricate(:custom_emoji) }

    subject { described_class.from_text(text, nil) }

    context 'with plain text' do
      let(:text) { 'Hello :coolcat:' }

      it 'returns records used via shortcodes in text' do
        is_expected.to include(emojo)
      end
    end

    context 'with html' do
      let(:text) { '<p>Hello :coolcat:</p>' }

      it 'returns records used via shortcodes in text' do
        is_expected.to include(emojo)
      end
    end
  end
end
