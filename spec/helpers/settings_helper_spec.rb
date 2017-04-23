# frozen_string_literal: true

require 'rails_helper'

describe SettingsHelper do
  describe 'the HUMAN_LOCALES constant' do
    it 'has the same number of keys as I18n locales exist' do
      options = I18n.available_locales.sort

      expect(described_class::HUMAN_LOCALES.keys.sort).to eq(options)
    end
  end
end
