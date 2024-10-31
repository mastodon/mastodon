# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatusTrend do
  describe 'Associations' do
    it { is_expected.to belong_to(:account).required }
    it { is_expected.to belong_to(:status).required }
  end

  describe '.locales' do
    before do
      Fabricate :status_trend, language: 'en'
      Fabricate :status_trend, language: 'en'
      Fabricate :status_trend, language: 'es'
    end

    it 'returns unique set of languages' do
      expect(described_class.locales)
        .to eq(['en', 'es'])
    end
  end
end
