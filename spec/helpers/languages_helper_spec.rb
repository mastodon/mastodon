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
        expect(helper.native_locale_name(:xxx)).to eq('xxx')
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
        expect(helper.standard_locale_name(:xxx)).to eq('xxx')
      end
    end

    context 'with a supported locale' do
      it 'finds the human readable standard name from a key' do
        expect(helper.standard_locale_name(:de)).to eq('German')
      end
    end
  end

  describe 'compound_locale_name' do
    context 'with a blank locale' do
      it 'defaults to a generic value' do
        expect(helper.compound_locale_name(nil)).to eq(I18n.t('generic.none'))
      end
    end

    context 'with a non-existent locale' do
      it 'returns the supplied locale value' do
        expect(helper.compound_locale_name(:xxx)).to eq('xxx')
      end
    end

    context 'with a supported locale' do
      it 'finds the human readable standard name from a key' do
        expect(helper.compound_locale_name(:de)).to eq('Deutsch – German')
      end
    end

    context 'with the current locale' do
      it 'finds the human readable standard name from a key' do
        expect(helper.compound_locale_name(:en)).to eq('English')
      end
    end
  end

  describe 'sorted_locales' do
    context 'when sorting with locale name' do
      it 'returns German after English' do
        I18n.with_locale(:en) do
          expect(helper.sorted_locale_keys(%w(de en))).to eq(%w(en de))
        end
      end

      it 'returns Englisch after Deutsch' do
        I18n.with_locale(:de) do
          expect(helper.sorted_locale_keys(%w(de en))).to eq(%w(de en))
        end
      end
    end

    context 'when sorting with local variants' do
      it 'returns variant in-line' do
        expect(helper.sorted_locale_keys(%w(en eo en-GB))).to eq(%w(en en-GB eo))
      end
    end
  end
end
