# frozen_string_literal: true

require 'rails_helper'

describe LanguagesHelper do
  describe 'the SUPPORTED_LOCALES constant' do
    it 'includes all i18n locales' do
      expect(Set.new(described_class::SUPPORTED_LOCALES.keys + described_class::REGIONAL_LOCALE_NAMES.keys)).to include(*I18n.available_locales)
    end
  end

  describe 'native_locale_name' do
    it 'finds the human readable native name from a key' do
      expect(helper.native_locale_name(:en)).to eq('English')
    end
  end

  describe 'standard_locale_name' do
    it 'finds the human readable standard name from a key' do
      expect(helper.standard_locale_name(:de)).to eq('German')
    end
  end
end
