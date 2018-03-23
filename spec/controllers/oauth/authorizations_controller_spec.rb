# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Oauth::AuthorizationsController, type: :controller do
  render_views

  let(:app) { Doorkeeper::Application.create!(name: 'test', redirect_uri: 'http://localhost/') }

  describe 'GET #new' do
    subject do
      get :new, params: { client_id: app.uid, response_type: 'code', redirect_uri: 'http://localhost/' }
    end

    shared_examples 'stores location for user' do
      it 'stores location for user' do
        subject
        expect(controller.stored_location_for(:user)).to eq "/oauth/authorize?client_id=#{app.uid}&redirect_uri=http%3A%2F%2Flocalhost%2F&response_type=code"
      end
    end

    context 'when signed in' do
      before do
        sign_in Fabricate(:user), scope: :user
      end

      it 'returns http success' do
        subject
        expect(response).to have_http_status(:success)
      end

      it 'gives options to authorize and deny' do
        subject
        expect(response.body).to match(/Authorize/)
      end

      include_examples 'stores location for user'
    end

    context 'when not signed in' do
      it 'redirects' do
        subject
        expect(response).to redirect_to '/auth/sign_in'
      end

      include_examples 'stores location for user'
    end
  end
end
