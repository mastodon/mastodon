# frozen_string_literal: true

require 'rails_helper'

describe SettingsHelper do
  describe 'the HUMAN_LOCALES constant' do
    it 'has the same number of keys as I18n locales exist' do
      options = I18n.available_locales

      expect(described_class::HUMAN_LOCALES.keys).to eq(options)
    end
  end

  describe 'human_locale' do
    it 'finds the human readable local description from a key' do
      # Ensure the value is as we expect
      expect(described_class::HUMAN_LOCALES[:en]).to eq('English')

      expect(helper.human_locale(:en)).to eq('English')
    end
  end
end
