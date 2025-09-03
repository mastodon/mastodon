# spec/lib/i18n_hsb_dsb_plural_spec.rb
require 'i18n'
require 'i18n/backend/pluralization'

RSpec.describe 'Sorbian pluralization (hsb/dsb)' do
  before(:all) do
    I18n::Backend::Simple.include I18n::Backend::Pluralization
  end

  before do
    I18n.backend.store_translations(:hsb, test: { one: 'one', two: 'two', few: 'few', other: 'other' })
    I18n.backend.store_translations(:dsb, test: { one: 'one', two: 'two', few: 'few', other: 'other' })
  end

  it 'selects correct categories for hsb' do
    I18n.with_locale(:hsb) do
      expect(I18n.t('test', count: 1)).to eq('one')
      expect(I18n.t('test', count: 2)).to eq('two')
      expect(I18n.t('test', count: 3)).to eq('few')
      expect(I18n.t('test', count: 4)).to eq('few')
      expect(I18n.t('test', count: 5)).to eq('other')
      expect(I18n.t('test', count: 101)).to eq('one')
    end
  end

  it 'selects correct categories for dsb' do
    I18n.with_locale(:dsb) do
      expect(I18n.t('test', count: 1)).to eq('one')
      expect(I18n.t('test', count: 2)).to eq('two')
      expect(I18n.t('test', count: 3)).to eq('few')
      expect(I18n.t('test', count: 5)).to eq('other')
      expect(I18n.t('test', count: 102)).to eq('two')
    end
  end
end
