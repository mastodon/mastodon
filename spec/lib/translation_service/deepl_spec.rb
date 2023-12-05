# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TranslationService::DeepL do
  subject(:service) { described_class.new(plan, 'my-api-key') }

  let(:plan) { 'advanced' }

  before do
    %w(api-free.deepl.com api.deepl.com).each do |host|
      stub_request(:get, "https://#{host}/v2/languages?type=source").to_return(
        body: '[{"language":"EN","name":"English"},{"language":"UK","name":"Ukrainian"}]'
      )
      stub_request(:get, "https://#{host}/v2/languages?type=target").to_return(
        body: '[{"language":"EN-GB","name":"English (British)"},{"language":"ZH","name":"Chinese"}]'
      )
    end
  end

  describe '#translate' do
    it 'returns translation with specified source language' do
      stub_request(:post, 'https://api.deepl.com/v2/translate')
        .with(body: 'text=Hasta+la+vista&source_lang=ES&target_lang=en&tag_handling=html')
        .to_return(body: '{"translations":[{"detected_source_language":"ES","text":"See you soon"}]}')

      translations = service.translate(['Hasta la vista'], 'es', 'en')
      expect(translations.size).to eq 1

      translation = translations.first
      expect(translation.detected_source_language).to eq 'es'
      expect(translation.provider).to eq 'DeepL.com'
      expect(translation.text).to eq 'See you soon'
    end

    it 'returns translation with auto-detected source language' do
      stub_request(:post, 'https://api.deepl.com/v2/translate')
        .with(body: 'text=Guten+Tag&source_lang&target_lang=en&tag_handling=html')
        .to_return(body: '{"translations":[{"detected_source_language":"DE","text":"Good morning"}]}')

      translations = service.translate(['Guten Tag'], nil, 'en')
      expect(translations.size).to eq 1

      translation = translations.first
      expect(translation.detected_source_language).to eq 'de'
      expect(translation.provider).to eq 'DeepL.com'
      expect(translation.text).to eq 'Good morning'
    end

    it 'returns translation of multiple texts' do
      stub_request(:post, 'https://api.deepl.com/v2/translate')
        .with(body: 'text=Guten+Morgen&text=Gute+Nacht&source_lang=DE&target_lang=en&tag_handling=html')
        .to_return(body: '{"translations":[{"detected_source_language":"DE","text":"Good morning"},{"detected_source_language":"DE","text":"Good night"}]}')

      translations = service.translate(['Guten Morgen', 'Gute Nacht'], 'de', 'en')
      expect(translations.size).to eq 2

      expect(translations.first.text).to eq 'Good morning'
      expect(translations.last.text).to eq 'Good night'
    end
  end

  describe '#languages' do
    it 'returns source languages' do
      expect(service.languages.keys).to eq [nil, 'en', 'uk']
    end

    it 'returns target languages for each source language' do
      expect(service.languages['en']).to eq %w(pt en-GB zh)
      expect(service.languages['uk']).to eq %w(en pt en-GB zh)
    end

    it 'returns target languages for auto-detection' do
      expect(service.languages[nil]).to eq %w(en pt en-GB zh)
    end
  end

  describe 'the paid and free plan api hostnames' do
    before do
      service.languages
    end

    context 'without a plan set' do
      it 'uses paid plan base URL and sends an API key' do
        expect(a_request(:get, 'https://api.deepl.com/v2/languages?type=source').with(headers: { Authorization: 'DeepL-Auth-Key my-api-key' })).to have_been_made.once
        expect(a_request(:get, 'https://api.deepl.com/v2/languages?type=target').with(headers: { Authorization: 'DeepL-Auth-Key my-api-key' })).to have_been_made.once
      end
    end

    context 'with the free plan' do
      let(:plan) { 'free' }

      it 'uses free plan base URL and sends an API key' do
        expect(a_request(:get, 'https://api-free.deepl.com/v2/languages?type=source').with(headers: { Authorization: 'DeepL-Auth-Key my-api-key' })).to have_been_made.once
        expect(a_request(:get, 'https://api-free.deepl.com/v2/languages?type=target').with(headers: { Authorization: 'DeepL-Auth-Key my-api-key' })).to have_been_made.once
      end
    end
  end
end
