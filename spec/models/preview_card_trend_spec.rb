# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PreviewCardTrend do
  describe 'Associations' do
    it { is_expected.to belong_to(:preview_card).required }
  end

  describe '.locales' do
    before do
      Fabricate :preview_card_trend, language: 'en'
      Fabricate :preview_card_trend, language: 'en'
      Fabricate :preview_card_trend, language: 'es'
    end

    it 'returns unique set of languages' do
      expect(described_class.locales)
        .to eq(['en', 'es'])
    end
  end
end
