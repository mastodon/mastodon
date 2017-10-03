# frozen_string_literal: true

require 'rails_helper'

describe Auth::ConfirmationsController, type: :controller do
  describe 'GET #new' do
    it 'returns http success' do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
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
end
