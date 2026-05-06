# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Statuses Translations' do
  let(:user)  { Fabricate(:user) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'read:statuses' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  context 'with an application token' do
    let(:token) { Fabricate(:accessible_access_token, resource_owner_id: nil, scopes: scopes) }

    describe 'POST /api/v1/statuses/:status_id/translate' do
      let(:status) { Fabricate(:status, account: user.account, text: 'Hola', language: 'es') }

      before do
        post "/api/v1/statuses/#{status.id}/translate", headers: headers
      end

      it 'returns http unprocessable entity' do
        expect(response).to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end

  context 'with an oauth token' do
    describe 'POST /api/v1/statuses/:status_id/translate' do
      subject { post "/api/v1/statuses/#{status.id}/translate", headers: headers }

      before do
        translation = TranslationService::Translation.new(text: 'Hello')
        service = instance_double(TranslationService::DeepL, translate: [translation])
        allow(TranslationService).to receive_messages(configured?: true, configured: service)
        Rails.cache.write('translation_service/languages', { 'es' => ['en'] })
      end

      context 'with a public status' do
        let(:status) { Fabricate(:status, account: user.account, text: 'Hola', language: 'es') }

        it 'returns http success' do
          subject

          expect(response)
            .to have_http_status(200)
          expect(response.media_type)
            .to eq('application/json')
        end
      end

      context 'with a public status marked with the same language as the current locale when translation backend cannot do same-language translation' do
        let(:status) { Fabricate(:status, account: user.account, text: 'Esto está en español pero está marcado como inglés.', language: 'en') }

        it 'returns http forbidden with error message' do
          subject

          expect(response)
            .to have_http_status(403)
          expect(response.media_type)
            .to eq('application/json')
          expect(response.parsed_body)
            .to include(error: /not allowed/)
        end
      end

      context 'with a private status' do
        let(:status) { Fabricate(:status, visibility: :private, account: user.account, text: 'Hola', language: 'es') }

        it 'returns http forbidden' do
          subject

          expect(response)
            .to have_http_status(403)
          expect(response.media_type)
            .to eq('application/json')
          expect(response.parsed_body)
            .to include(error: /not allowed/)
        end
      end
    end
  end
end
