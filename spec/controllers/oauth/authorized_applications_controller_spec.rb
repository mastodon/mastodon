# frozen_string_literal: true

require 'rails_helper'

describe Oauth::AuthorizedApplicationsController do
  render_views

  describe 'GET #index' do
    subject do
      get :index
    end

    shared_examples 'stores location for user' do
      it 'stores location for user' do
        subject
        expect(controller.stored_location_for(:user)).to eq '/oauth/authorized_applications'
      end
    end

    context 'when signed in' do
      before do
        sign_in Fabricate(:user), scope: :user
      end

      it 'returns http success' do
        subject
        expect(response).to have_http_status(200)
      end

      it 'returns private cache control headers' do
        subject
        expect(response.headers['Cache-Control']).to include('private, no-store')
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

  describe 'DELETE #destroy' do
    let!(:user) { Fabricate(:user) }
    let!(:application) { Fabricate(:application) }
    let!(:access_token) { Fabricate(:accessible_access_token, application: application, resource_owner_id: user.id) }
    let!(:web_push_subscription) { Fabricate(:web_push_subscription, user: user, access_token: access_token) }

    before do
      sign_in user, scope: :user
      post :destroy, params: { id: application.id }
    end

    it 'revokes access tokens for the application' do
      expect(Doorkeeper::AccessToken.where(application: application).first.revoked_at).to_not be_nil
    end

    it 'removes subscriptions for the application\'s access tokens' do
      expect(Web::PushSubscription.where(user: user).count).to eq 0
    end
  end
end
