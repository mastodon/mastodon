# frozen_string_literal: true

require 'rails_helper'

describe LanguagesHelper do
  describe 'the SUPPORTED_LOCALES constant' do
    it 'includes all i18n locales' do
      expect(Set.new(described_class::SUPPORTED_LOCALES.keys + described_class::REGIONAL_LOCALE_NAMES.keys)).to include(*I18n.available_locales)
    end
  end

  describe 'native_locale_name' do
    context 'with a blank locale' do
      it 'defaults to a generic value' do
        expect(helper.native_locale_name(nil)).to eq(I18n.t('generic.none'))
      end
    end

    context 'with a locale of `und`' do
      it 'defaults to a generic value' do
        expect(helper.native_locale_name('und')).to eq(I18n.t('generic.none'))
      end
    end

    context 'with a supported locale' do
      it 'finds the human readable native name from a key' do
        expect(helper.native_locale_name(:de)).to eq('Deutsch')
      end
    end

    context 'with a regional locale' do
      it 'finds the human readable regional name from a key' do
        expect(helper.native_locale_name('en-GB')).to eq('English (British)')
      end
    end

    context 'with a non-existent locale' do
      it 'returns the supplied locale value' do
        expect(helper.native_locale_name(:xxx)).to eq(:xxx)
      end
    end
  end

  describe 'standard_locale_name' do
    context 'with a blank locale' do
      it 'defaults to a generic value' do
        expect(helper.standard_locale_name(nil)).to eq(I18n.t('generic.none'))
      end
    end

    context 'with a non-existent locale' do
      it 'returns the supplied locale value' do
        expect(helper.standard_locale_name(:xxx)).to eq(:xxx)
      end
    end

    context 'with a supported locale' do
      it 'finds the human readable standard name from a key' do
        expect(helper.standard_locale_name(:de)).to eq('German')
      end
    end
  end
end
