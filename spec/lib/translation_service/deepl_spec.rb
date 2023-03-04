# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TranslationService::DeepL do
  subject(:service) { described_class.new(plan, 'my-api-key') }

  let(:plan) { 'advanced' }

  before do
    stub_request(:get, 'https://api.deepl.com/v2/languages?type=source').to_return(
      body: '[{"language":"EN","name":"English"},{"language":"UK","name":"Ukrainian"}]'
    )
    stub_request(:get, 'https://api.deepl.com/v2/languages?type=target').to_return(
      body: '[{"language":"EN-GB","name":"English (British)"},{"language":"ZH","name":"Chinese"}]'
    )
  end

  describe '#supported?' do
    it 'supports included languages as source and target languages' do
      expect(service.supported?('uk', 'en')).to be true
    end

    it 'supports auto-detecting source language' do
      expect(service.supported?(nil, 'en')).to be true
    end

    it 'supports "en" and "pt" as target languages though not included in language list' do
      expect(service.supported?('uk', 'en')).to be true
      expect(service.supported?('uk', 'pt')).to be true
    end

    it 'does not support non-included language as target language' do
      expect(service.supported?('uk', 'nl')).to be false
    end

    it 'does not support non-included language as source language' do
      expect(service.supported?('da', 'en')).to be false
    end
  end

  describe '#translate' do
    it 'returns translation with specified source language' do
      stub_request(:post, 'https://api.deepl.com/v2/translate')
        .with(body: 'text=Hasta+la+vista&source_lang=ES&target_lang=en&tag_handling=html')
        .to_return(body: '{"translations":[{"detected_source_language":"ES","text":"See you soon"}]}')

      translation = service.translate('Hasta la vista', 'es', 'en')
      expect(translation.detected_source_language).to eq 'es'
      expect(translation.provider).to eq 'DeepL.com'
      expect(translation.text).to eq 'See you soon'
    end

    it 'returns translation with auto-detected source language' do
      stub_request(:post, 'https://api.deepl.com/v2/translate')
        .with(body: 'text=Guten+Tag&source_lang&target_lang=en&tag_handling=html')
        .to_return(body: '{"translations":[{"detected_source_language":"DE","text":"Good Morning"}]}')

      translation = service.translate('Guten Tag', nil, 'en')
      expect(translation.detected_source_language).to eq 'de'
      expect(translation.provider).to eq 'DeepL.com'
      expect(translation.text).to eq 'Good Morning'
    end
  end

  describe '#languages?' do
    it 'returns source languages' do
      expect(service.send(:languages, 'source')).to eq ['en', 'uk', nil]
    end

    it 'returns target languages' do
      expect(service.send(:languages, 'target')).to eq %w(en-gb zh en pt)
    end
  end

  describe '#request' do
    before do
      stub_request(:any, //)
      # rubocop:disable Lint/EmptyBlock
      service.send(:request, :get, '/v2/languages') { |res| }
      # rubocop:enable Lint/EmptyBlock
    end

    it 'uses paid plan base URL' do
      expect(a_request(:get, 'https://api.deepl.com/v2/languages')).to have_been_made.once
    end

    context 'with free plan' do
      let(:plan) { 'free' }

      it 'uses free plan base URL' do
        expect(a_request(:get, 'https://api-free.deepl.com/v2/languages')).to have_been_made.once
      end
    end

    it 'sends API key' do
      expect(a_request(:get, 'https://api.deepl.com/v2/languages').with(headers: { Authorization: 'DeepL-Auth-Key my-api-key' })).to have_been_made.once
    end
  end
end
