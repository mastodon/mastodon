# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Apps' do
  describe 'POST /api/v1/apps' do
    subject do
      post '/api/v1/apps', params: params
    end

    let(:client_name)   { 'Test app' }
    let(:scopes)        { nil }
    let(:redirect_uris) { 'urn:ietf:wg:oauth:2.0:oob' }
    let(:website)       { nil }

    let(:params) do
      {
        client_name: client_name,
        redirect_uris: redirect_uris,
        scopes: scopes,
        website: website,
      }
    end

    context 'with valid params' do
      it 'returns http success' do
        subject

        expect(response).to have_http_status(200)
      end

      it 'creates an OAuth app' do
        subject

        expect(Doorkeeper::Application.find_by(name: client_name)).to be_present
      end

      it 'returns client ID and client secret' do
        subject

        body = body_as_json

        expect(body[:client_id]).to be_present
        expect(body[:client_secret]).to be_present
      end
    end

    context 'with an unsupported scope' do
      let(:scopes) { 'hoge' }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
      end
    end

    context 'with many duplicate scopes' do
      let(:scopes) { (%w(read) * 40).join(' ') }

      it 'returns http success' do
        subject

        expect(response).to have_http_status(200)
      end

      it 'only saves the scope once' do
        subject

        expect(Doorkeeper::Application.find_by(name: client_name).scopes.to_s).to eq 'read'
      end
    end

    context 'with a too-long name' do
      let(:client_name) { 'hoge' * 20 }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
      end
    end

    context 'with a too-long website' do
      let(:website) { "https://foo.bar/#{'hoge' * 2_000}" }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
      end
    end

    context 'with a too-long redirect_uris' do
      let(:redirect_uris) { "https://foo.bar/#{'hoge' * 2_000}" }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
      end
    end

    context 'without required params' do
      let(:client_name)   { '' }
      let(:redirect_uris) { '' }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
      end
    end
  end
end
