# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LanguagesHelper do
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

  describe 'sorted_locales' do
    context 'when sorting with native name' do
      it 'returns Suomi after Gàidhlig' do
        expect(described_class.sorted_locale_keys(%w(fi gd))).to eq(%w(gd fi))
      end
    end

    context 'when sorting with diacritics' do
      it 'returns Íslensk before Suomi' do
        expect(described_class.sorted_locale_keys(%w(fi is))).to eq(%w(is fi))
      end
    end

    context 'when sorting with non-Latin' do
      it 'returns Suomi before Amharic' do
        expect(described_class.sorted_locale_keys(%w(am fi))).to eq(%w(fi am))
      end
    end

    context 'when sorting with local variants' do
      it 'returns variant in-line' do
        expect(described_class.sorted_locale_keys(%w(en eo en-GB))).to eq(%w(en en-GB eo))
      end
    end
  end

  describe '#valid_locale_or_nil' do
    subject { helper.valid_locale_or_nil(string) }

    context 'when string is nil' do
      let(:string) { nil }

      it { is_expected.to be_nil }
    end

    context 'when string is empty' do
      let(:string) { '' }

      it { is_expected.to be_nil }
    end

    context 'when string is valid locale' do
      let(:string) { 'en' }

      it { is_expected.to eq('en') }
    end

    context 'when string contains region' do
      context 'when base locale is valid' do
        let(:string) { 'en-US' }

        it { is_expected.to eq('en') }
      end

      context 'when base locale is not valid' do
        let(:string) { 'qq-US' }

        it { is_expected.to be_nil }
      end
    end
  end
end
