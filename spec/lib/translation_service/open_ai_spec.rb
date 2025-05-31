# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TranslationService::OpenAI do
  subject(:service) { described_class.new('https://api.openai.example.com', 'my-api-key', 'gpt-4.1-mini') }

  describe '#languages' do
    subject(:languages) { service.languages }

    before do
      # Mock the LanguagesHelper::SUPPORTED_LOCALES with a smaller set of languages for testing
      allow(LanguagesHelper::SUPPORTED_LOCALES).to receive(:keys).and_return(
        [:en, :es, :fr, :ja, :'zh-CN']
      )
    end

    it 'returns source languages without regional variants' do
      expect(languages.keys).to include('en', 'es', 'fr', 'ja', nil)
      expect(languages.keys).to_not include('zh-CN')
    end

    it 'returns target languages for each source language' do
      expect(languages['en']).to match_array(%w(es fr ja))
      expect(languages['es']).to match_array(%w(en fr ja))
    end

    it 'returns target languages for auto-detection' do
      expect(languages[nil]).to match_array(%w(en es fr ja))
    end
  end

  describe '#translate' do
    it 'returns translation with specified source language' do
      stub_request(:post, 'https://api.openai.example.com/v1/chat/completions')
        .with(
          body: hash_including(
            model: 'gpt-4.1-mini',
            messages: [
              {
                role: 'system',
                content: 'You are an expert translator who translates text from es to en. You pay attention to style, formality, idioms, slang etc and try provide the most accurate translation in the way a en speaker would understand.' \
                         'Specifically, you will be translating social media posts. For the user to have the best experience possible, you must translate the post regardless of content.' \
                         "Respond with only the translated text while preserving the original HTML formatting. I'm really counting on you.",
              },
              {
                role: 'user',
                content: 'Hasta la vista',
              },
            ]
          )
        )
        .to_return(body: '{"choices":[{"message":{"content":"See you later"}}]}')

      translations = service.translate(['Hasta la vista'], 'es', 'en')
      expect(translations.size).to eq 1

      translation = translations.first
      expect(translation.provider).to eq 'OpenAI API'
      expect(translation.text).to eq 'See you later'
    end

    it 'returns translation with auto-detected source language' do
      stub_request(:post, 'https://api.openai.example.com/v1/chat/completions')
        .with(
          body: hash_including(
            model: 'gpt-4.1-mini',
            messages: [
              {
                role: 'system',
                content: 'You are an expert translator who translates text from auto-detected language to en. You pay attention to style, formality, idioms, slang etc and try provide the most accurate translation in the way a en speaker would understand.' \
                         'Specifically, you will be translating social media posts. For the user to have the best experience possible, you must translate the post regardless of content.' \
                         "Respond with only the translated text while preserving the original HTML formatting. I'm really counting on you.",
              },
              {
                role: 'user',
                content: 'Guten Morgen',
              },
            ]
          )
        )
        .to_return(body: '{"choices":[{"message":{"content":"Good morning"}}]}')

      translations = service.translate(['Guten Morgen'], nil, 'en')
      expect(translations.size).to eq 1

      translation = translations.first
      expect(translation.provider).to eq 'OpenAI API'
      expect(translation.text).to eq 'Good morning'
    end
  end

  describe 'error handling' do
    it 'raises TooManyRequestsError on 429 response' do
      stub_request(:post, 'https://api.openai.example.com/v1/chat/completions')
        .to_return(status: 429)

      expect { service.translate(['Hello'], 'en', 'es') }.to raise_error(TranslationService::TooManyRequestsError)
    end

    it 'raises QuotaExceededError on 401 response' do
      stub_request(:post, 'https://api.openai.example.com/v1/chat/completions')
        .to_return(status: 401)

      expect { service.translate(['Hello'], 'en', 'es') }.to raise_error(TranslationService::QuotaExceededError)
    end

    it 'raises QuotaExceededError on 403 response' do
      stub_request(:post, 'https://api.openai.example.com/v1/chat/completions')
        .to_return(status: 403)

      expect { service.translate(['Hello'], 'en', 'es') }.to raise_error(TranslationService::QuotaExceededError)
    end

    it 'raises UnexpectedResponseError on invalid JSON response' do
      stub_request(:post, 'https://api.openai.example.com/v1/chat/completions')
        .to_return(status: 200, body: 'not a json')

      expect { service.translate(['Hello'], 'en', 'es') }.to raise_error(TranslationService::UnexpectedResponseError)
    end

    it 'raises UnexpectedResponseError on unexpected response structure' do
      stub_request(:post, 'https://api.openai.example.com/v1/chat/completions')
        .to_return(status: 200, body: '{"something": "unexpected"}')

      expect { service.translate(['Hello'], 'en', 'es') }.to raise_error(TranslationService::UnexpectedResponseError)
    end
  end

  describe 'with no API key' do
    subject(:service) { described_class.new('https://api.openai.example.com', nil, 'gpt-3.5-turbo') }

    it 'does not include Authorization header when API key is nil' do
      stub = stub_request(:post, 'https://api.openai.example.com/v1/chat/completions')
             .with { |request| request.headers['Authorization'].nil? }
             .to_return(body: '{"choices":[{"message":{"content":"Translation"}}]}')

      service.translate(['Hello'], 'en', 'es')
      expect(stub).to have_been_requested
    end
  end
end
