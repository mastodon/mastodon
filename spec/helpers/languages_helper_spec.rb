# frozen_string_literal: true

require 'rails_helper'

describe LanguagesHelper do
  describe 'the SUPPORTED_LOCALES constant' do
    it 'includes all i18n locales' do
      expect(Set.new(described_class::SUPPORTED_LOCALES.keys + described_class::REGIONAL_LOCALE_NAMES.keys)).to include(*I18n.available_locales)
    end
  end

  describe 'human_locale' do
    it 'finds the human readable local description from a key' do
      expect(helper.human_locale(:en)).to eq('English')
    end
  end
end
