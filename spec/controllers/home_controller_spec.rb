require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  render_views

  describe 'GET #index' do
    context 'when not signed in' do
      it 'redirects to about page' do
        get :index
        expect(response).to redirect_to(about_path)
      end
    end

    context 'when signed in' do
      let(:user) { Fabricate(:user) }
      subject do
        sign_in(user)
        get :index
      end

      it 'assigns @body_classes' do
        subject
        expect(assigns(:body_classes)).to eq 'app-body'
      end

      it 'assigns @token' do
        app = Doorkeeper::Application.create!(name: 'Web', superapp: true, redirect_uri: Doorkeeper.configuration.native_redirect_uri)
        allow(Doorkeeper.configuration).to receive(:access_token_expires_in).and_return(42)

        subject
        token = Doorkeeper::AccessToken.find_by(token: assigns(:token))

        expect(token.application).to eq app
        expect(token.resource_owner_id).to eq user.id
        expect(token.scopes).to eq Doorkeeper::OAuth::Scopes.from_string('read write follow')
        expect(token.expires_in_seconds).to eq 42
        expect(token.use_refresh_token?).to eq false
      end

      it 'assigns @web_settings for {} if not available' do
        subject
        expect(assigns(:web_settings)).to eq({})
      end

      it 'assigns @web_settings for Web::Setting if available' do
        setting = Fabricate('Web::Setting', data: '{"home":{}}', user: user)
        subject
        expect(assigns(:web_settings)).to eq setting.data
      end

      it 'assigns @admin' do
        admin = Fabricate(:account)
        Setting.site_contact_username = admin.username
        subject
        expect(assigns(:admin)).to eq admin
      end

      it 'assigns streaming_api_base_url' do
        subject
        expect(assigns(:streaming_api_base_url)).to eq 'ws://localhost:4000'
      end
    end
  end
end
