# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Apps' do
  describe 'POST /api/v1/apps' do
    subject do
      post '/api/v1/apps', params: params
    end

    let(:client_name)   { 'Test app' }
    let(:scopes)        { 'read write' }
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
      it 'creates an OAuth app', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(Doorkeeper::Application.find_by(name: client_name)).to be_present
        expect(Doorkeeper::Application.find_by(name: client_name).scopes.to_s).to eq 'read write'

        body = body_as_json

        expect(body[:client_id]).to be_present
        expect(body[:client_secret]).to be_present
        expect(body[:scopes]).to eq ['read', 'write']
        expect(body[:redirect_uris]).to eq [redirect_uris]
      end
    end

    context 'without scopes being supplied' do
      let(:scopes) { nil }

      it 'creates an OAuth App with the default scope' do
        subject

        expect(response).to have_http_status(200)
        expect(Doorkeeper::Application.find_by(name: client_name)).to be_present

        body = body_as_json

        expect(body[:scopes]).to eq Doorkeeper.config.default_scopes.to_a
      end
    end

    # FIXME: This is a bug: https://github.com/mastodon/mastodon/issues/30152
    context 'with scopes as an array' do
      let(:scopes) { %w(read write follow) }

      it 'creates an OAuth App with the default scope' do
        subject

        expect(response).to have_http_status(200)

        app = Doorkeeper::Application.find_by(name: client_name)

        expect(app).to be_present
        expect(app.scopes.to_s).to eq 'read'

        body = body_as_json

        expect(body[:scopes]).to eq ['read']
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

      it 'only saves the scope once', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
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

    context 'with multiple redirect_uris as a string' do
      let(:redirect_uris) { "https://redirect1.example/\napp://redirect2.example/" }

      it 'creates an OAuth application with multiple redirect URIs' do
        subject

        expect(response).to have_http_status(200)

        app = Doorkeeper::Application.find_by(name: client_name)

        expect(app).to be_present
        expect(app.redirect_uri).to eq redirect_uris

        body = body_as_json

        expect(body[:redirect_uri]).to eq 'https://redirect1.example/'
        expect(body[:redirect_uris]).to eq redirect_uris.split
      end
    end

    context 'with multiple redirect_uris as an array' do
      let(:redirect_uris) { ['https://redirect1.example/', 'app://redirect2.example/'] }

      it 'creates an OAuth application with multiple redirect URIs' do
        subject

        expect(response).to have_http_status(200)

        app = Doorkeeper::Application.find_by(name: client_name)

        expect(app).to be_present
        expect(app.redirect_uri).to eq redirect_uris.join "\n"

        body = body_as_json

        expect(body[:redirect_uri]).to eq 'https://redirect1.example/'
        expect(body[:redirect_uris]).to eq redirect_uris
      end
    end

    context 'with an empty redirect_uris array' do
      let(:redirect_uris) { [] }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
      end
    end

    context 'with just a newline as the redirect_uris string' do
      let(:redirect_uris) { "\n" }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
      end
    end

    context 'with an empty redirect_uris string' do
      let(:redirect_uris) { '' }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
      end
    end

    context 'without a required param' do
      let(:client_name) { '' }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
      end
    end

    context 'with a website' do
      let(:website) { 'https://app.example/' }

      it 'creates an OAuth application with the website specified' do
        subject

        expect(response).to have_http_status(200)

        app = Doorkeeper::Application.find_by(name: client_name)

        expect(app).to be_present
        expect(app.website).to eq website
      end
    end
  end
end
