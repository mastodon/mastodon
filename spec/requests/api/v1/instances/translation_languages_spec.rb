# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Translation Languages' do
  describe 'GET /api/v1/instances/translation_languages' do
    context 'when no translation service is configured' do
      it 'returns empty language matrix', :aggregate_failures do
        get api_v1_instance_translation_languages_path

        expect(response)
          .to have_http_status(200)

        expect(response.parsed_body)
          .to eq({})
      end
    end

    context 'when a translation service is configured' do
      before { configure_translation_service }

      it 'returns language matrix', :aggregate_failures do
        get api_v1_instance_translation_languages_path

        expect(response)
          .to have_http_status(200)

        expect(response.parsed_body)
          .to match({ und: %w(en de), en: ['de'] })
      end

      private

      def configure_translation_service
        allow(TranslationService).to receive_messages(configured?: true, configured: service_double)
      end

      def service_double
        instance_double(TranslationService::DeepL, languages: { nil => %w(en de), 'en' => ['de'] })
      end
    end
  end
end
