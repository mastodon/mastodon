# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Auth::PasswordsController do
  include Devise::Test::ControllerHelpers

  describe 'GET #new' do
    it 'returns http success' do
      request.env['devise.mapping'] = Devise.mappings[:user]
      get :new
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #edit' do
    let(:user) { Fabricate(:user) }

    before do
      request.env['devise.mapping'] = Devise.mappings[:user]
    end

    context 'with valid reset_password_token' do
      it 'returns http success' do
        token = user.send_reset_password_instructions

        get :edit, params: { reset_password_token: token }

        expect(response).to have_http_status(200)
      end
    end

    context 'with invalid reset_password_token' do
      it 'redirects to #new' do
        get :edit, params: { reset_password_token: 'some_invalid_value' }
        expect(response).to redirect_to subject.new_password_path(subject.send(:resource_name))
      end
    end
  end

  describe 'POST #update' do
    let(:user) { Fabricate(:user) }
    let(:password) { 'reset0password' }

    before do
      request.env['devise.mapping'] = Devise.mappings[:user]
    end

    context 'with valid reset_password_token' do
      let!(:session_activation) { Fabricate(:session_activation, user: user) }
      let!(:access_token) { Fabricate(:access_token, resource_owner_id: user.id) }
      let!(:web_push_subscription) { Fabricate(:web_push_subscription, access_token: access_token) }

      before do
        token = user.send_reset_password_instructions

        post :update, params: { user: { password: password, password_confirmation: password, reset_password_token: token } }
      end

      it 'redirect to sign in' do
        expect(response).to redirect_to '/auth/sign_in'
      end

      it 'changes password' do
        this_user = User.find(user.id)

        expect(this_user).to_not be_nil
        expect(this_user.valid_password?(password)).to be true
      end

      it 'deactivates all sessions' do
        expect(user.session_activations.count).to eq 0
        expect { session_activation.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'revokes all access tokens' do
        expect(Doorkeeper::AccessToken.active_for(user).count).to eq 0
      end

      it 'removes push subscriptions' do
        expect(Web::PushSubscription.where(user: user).or(Web::PushSubscription.where(access_token: access_token)).count).to eq 0
        expect { web_push_subscription.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with invalid reset_password_token' do
      before do
        post :update, params: { user: { password: password, password_confirmation: password, reset_password_token: 'some_invalid_value' } }
      end

      it 'renders reset password' do
        expect(response).to render_template(:new)
      end

      it 'retains password' do
        this_user = User.find(user.id)

        expect(this_user).to_not be_nil
        expect(this_user.external_or_valid_password?(user.password)).to be true
      end
    end
  end
end
