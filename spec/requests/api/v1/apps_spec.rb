# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Apps' do
  describe 'POST /api/v1/apps' do
    subject do
      post '/api/v1/apps', params: params
    end

    let(:client_name)   { 'Test app' }
    let(:scopes)        { 'read write' }
    let(:redirect_uri)  { 'urn:ietf:wg:oauth:2.0:oob' }
    let(:redirect_uris) { [redirect_uri] }
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
        expect(response.content_type)
          .to start_with('application/json')

        app = Doorkeeper::Application.find_by(name: client_name)

        expect(app).to be_present
        expect(app.scopes.to_s).to eq scopes
        expect(app.redirect_uris).to eq redirect_uris

        expect(response.parsed_body).to match(
          a_hash_including(
            id: app.id.to_s,
            client_id: app.uid,
            client_secret: app.secret,
            name: client_name,
            website: website,
            scopes: ['read', 'write'],
            redirect_uris: redirect_uris,
            # Deprecated properties as of 4.3:
            redirect_uri: redirect_uri,
            vapid_key: Rails.configuration.x.vapid_public_key
          )
        )
      end
    end

    context 'without scopes being supplied' do
      let(:scopes) { nil }

      it 'creates an OAuth App with the default scope' do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(Doorkeeper::Application.find_by(name: client_name)).to be_present

        expect(response.parsed_body)
          .to include(
            scopes: Doorkeeper.config.default_scopes.to_a
          )
      end
    end

    # FIXME: This is a bug: https://github.com/mastodon/mastodon/issues/30152
    context 'with scopes as an array' do
      let(:scopes) { %w(read write follow) }

      it 'creates an OAuth App with the default scope' do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')

        app = Doorkeeper::Application.find_by(name: client_name)

        expect(app).to be_present
        expect(app.scopes.to_s).to eq 'read'

        expect(response.parsed_body)
          .to include(
            scopes: %w(read)
          )
      end
    end

    context 'with an unsupported scope' do
      let(:scopes) { 'hoge' }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'with many duplicate scopes' do
      let(:scopes) { (%w(read) * 40).join(' ') }

      it 'only saves the scope once', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(Doorkeeper::Application.find_by(name: client_name).scopes.to_s).to eq 'read'
      end
    end

    context 'with a too-long name' do
      let(:client_name) { 'hoge' * 20 }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'with a too-long website' do
      let(:website) { "https://foo.bar/#{'hoge' * 2_000}" }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'with a too-long redirect_uri' do
      let(:redirect_uris) { "https://app.example/#{'hoge' * 2_000}" }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    # NOTE: This spec currently tests the same as the "with a too-long redirect_uri test case"
    context 'with too many redirect_uris' do
      let(:redirect_uris) { (0...500).map { |i| "https://app.example/#{i}/callback" } }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'with multiple redirect_uris as a string' do
      let(:redirect_uris) { "https://redirect1.example/\napp://redirect2.example/" }

      it 'creates an OAuth application with multiple redirect URIs' do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')

        app = Doorkeeper::Application.find_by(name: client_name)

        expect(app).to be_present
        expect(app.redirect_uri).to eq redirect_uris
        expect(app.redirect_uris).to eq redirect_uris.split

        expect(response.parsed_body)
          .to include(
            redirect_uri: redirect_uris,
            redirect_uris: redirect_uris.split
          )
      end
    end

    context 'with multiple redirect_uris as an array' do
      let(:redirect_uris) { ['https://redirect1.example/', 'app://redirect2.example/'] }

      it 'creates an OAuth application with multiple redirect URIs' do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')

        app = Doorkeeper::Application.find_by(name: client_name)

        expect(app).to be_present
        expect(app.redirect_uri).to eq redirect_uris.join "\n"
        expect(app.redirect_uris).to eq redirect_uris

        expect(response.parsed_body)
          .to include(
            redirect_uri: redirect_uris.join("\n"),
            redirect_uris: redirect_uris
          )
      end
    end

    context 'with an empty redirect_uris array' do
      let(:redirect_uris) { [] }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'with just a newline as the redirect_uris string' do
      let(:redirect_uris) { "\n" }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'with an empty redirect_uris string' do
      let(:redirect_uris) { '' }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'without a required param' do
      let(:client_name) { '' }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'with a website' do
      let(:website) { 'https://app.example/' }

      it 'creates an OAuth application with the website specified' do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')

        app = Doorkeeper::Application.find_by(name: client_name)

        expect(app).to be_present
        expect(app.website).to eq website
      end
    end
  end
end
