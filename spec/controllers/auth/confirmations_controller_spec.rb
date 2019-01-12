# frozen_string_literal: true

require 'rails_helper'

describe Auth::ConfirmationsController, type: :controller do
  render_views

  describe 'GET #new' do
    it 'returns http success' do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      get :new
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #show' do
    context 'when user is unconfirmed' do
      let!(:user) { Fabricate(:user, confirmation_token: 'foobar', confirmed_at: nil) }

      before do
        allow(BootstrapTimelineWorker).to receive(:perform_async)
        @request.env['devise.mapping'] = Devise.mappings[:user]
        get :show, params: { confirmation_token: 'foobar' }
      end

      it 'redirects to login' do
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'queues up bootstrapping of home timeline' do
        expect(BootstrapTimelineWorker).to have_received(:perform_async).with(user.account_id)
      end
    end

    context 'when user is updating email' do
      let!(:user) { Fabricate(:user, confirmation_token: 'foobar', unconfirmed_email: 'new-email@example.com') }

      before do
        allow(BootstrapTimelineWorker).to receive(:perform_async)
        @request.env['devise.mapping'] = Devise.mappings[:user]
        get :show, params: { confirmation_token: 'foobar' }
      end

      it 'redirects to login' do
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'does not queue up bootstrapping of home timeline' do
        expect(BootstrapTimelineWorker).to_not have_received(:perform_async)
      end
    end
  end

  describe 'GET #finish_signup' do
    subject { get :finish_signup }

    let(:user) { Fabricate(:user) }
    before do
      sign_in user, scope: :user
      @request.env['devise.mapping'] = Devise.mappings[:user]
    end

    it 'renders finish_signup' do
      is_expected.to render_template :finish_signup
      expect(assigns(:user)).to have_attributes id: user.id
    end
  end

  describe 'PATCH #finish_signup' do
    subject { patch :finish_signup, params: { user: { email: email } } }

    let(:user) { Fabricate(:user) }
    before do
      sign_in user, scope: :user
      @request.env['devise.mapping'] = Devise.mappings[:user]
    end

    context 'when email is valid' do
      let(:email) { 'new_' + user.email }

      it 'redirects to root_path' do
        is_expected.to redirect_to root_path
      end
    end

    context 'when email is invalid' do
      let(:email) { '' }

      it 'renders finish_signup' do
        is_expected.to render_template :finish_signup
      end
    end
  end
end
