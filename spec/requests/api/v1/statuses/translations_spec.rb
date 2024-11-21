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
      let(:status) { Fabricate(:status, account: user.account, text: 'Hola', language: 'es') }

      before do
        translation = TranslationService::Translation.new(text: 'Hello')
        service = instance_double(TranslationService::DeepL, translate: [translation])
        allow(TranslationService).to receive_messages(configured?: true, configured: service)
        Rails.cache.write('translation_service/languages', { 'es' => ['en'] })
        post "/api/v1/statuses/#{status.id}/translate", headers: headers
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end
end
