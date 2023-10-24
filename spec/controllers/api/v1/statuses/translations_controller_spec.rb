# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Statuses::TranslationsController do
  render_views

  let(:user)  { Fabricate(:user) }
  let(:app)   { Fabricate(:application, name: 'Test app', website: 'http://testapp.com') }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read:statuses', application: app) }

  context 'with an oauth token' do
    before do
      allow(controller).to receive(:doorkeeper_token) { token }
    end

    describe 'POST #create' do
      let(:status) { Fabricate(:status, account: user.account, text: 'Hola', language: 'es') }

      before do
        translation = TranslationService::Translation.new(text: 'Hello')
        service = instance_double(TranslationService::DeepL, translate: [translation])
        allow(TranslationService).to receive_messages(configured?: true, configured: service)
        Rails.cache.write('translation_service/languages', { 'es' => ['en'] })
        post :create, params: { status_id: status.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end
    end
  end
end
