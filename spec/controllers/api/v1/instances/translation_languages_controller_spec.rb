# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Instances::TranslationLanguagesController do
  describe 'GET #show' do
    context 'when no translation service is configured' do
      it 'returns empty language matrix' do
        get :show

        expect(response).to have_http_status(200)
        expect(body_as_json).to eq({})
      end
    end

    context 'when a translation service is configured' do
      before do
        service = instance_double(TranslationService::DeepL, languages: { nil => %w(en de), 'en' => ['de'] })
        allow(TranslationService).to receive(:configured?).and_return(true)
        allow(TranslationService).to receive(:configured).and_return(service)
      end

      it 'returns language matrix' do
        get :show

        expect(response).to have_http_status(200)
        expect(body_as_json).to eq({ und: %w(en de), en: ['de'] })
      end
    end
  end
end
