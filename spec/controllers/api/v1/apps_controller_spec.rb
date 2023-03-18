# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::AppsController, type: :controller do
  render_views

  describe 'POST #create' do
    let(:client_name) { 'Test app' }
    let(:scopes) { nil }
    let(:redirect_uris) { 'urn:ietf:wg:oauth:2.0:oob' }
    let(:website) { nil }

    let(:app_params) do
      {
        client_name: client_name,
        redirect_uris: redirect_uris,
        scopes: scopes,
        website: website,
      }
    end

    before do
      post :create, params: app_params
    end

    context 'with valid params' do
      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'creates an OAuth app' do
        expect(Doorkeeper::Application.find_by(name: client_name)).to_not be_nil
      end

      it 'returns client ID and client secret' do
        json = body_as_json

        expect(json[:client_id]).to_not be_blank
        expect(json[:client_secret]).to_not be_blank
      end
    end

    context 'with an unsupported scope' do
      let(:scopes) { 'hoge' }

      it 'returns http unprocessable entity' do
        expect(response).to have_http_status(422)
      end
    end

    context 'with many duplicate scopes' do
      let(:scopes) { (%w(read) * 40).join(' ') }

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'only saves the scope once' do
        expect(Doorkeeper::Application.find_by(name: client_name).scopes.to_s).to eq 'read'
      end
    end

    context 'with a too-long name' do
      let(:client_name) { 'hoge' * 20 }

      it 'returns http unprocessable entity' do
        expect(response).to have_http_status(422)
      end
    end

    context 'with a too-long website' do
      let(:website) { "https://foo.bar/#{'hoge' * 2_000}" }

      it 'returns http unprocessable entity' do
        expect(response).to have_http_status(422)
      end
    end

    context 'with a too-long redirect_uris' do
      let(:redirect_uris) { "https://foo.bar/#{'hoge' * 2_000}" }

      it 'returns http unprocessable entity' do
        expect(response).to have_http_status(422)
      end
    end
  end
end
