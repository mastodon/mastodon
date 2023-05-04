# frozen_string_literal: true

require 'rails_helper'

describe Settings::ExportsController do
  render_views

  describe 'GET #show' do
    context 'when signed in' do
      let(:user) { Fabricate(:user) }

      before do
        sign_in user, scope: :user
        get :show
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'returns private cache control headers' do
        expect(response.headers['Cache-Control']).to include('private, no-store')
      end
    end

    context 'when not signed in' do
      it 'redirects' do
        get :show
        expect(response).to redirect_to '/auth/sign_in'
      end
    end
  end

  describe 'POST #create' do
    before do
      sign_in Fabricate(:user), scope: :user
    end

    it 'redirects to settings_export_path' do
      post :create
      expect(response).to redirect_to(settings_export_path)
    end

    it 'queues BackupWorker job by 1' do
      Sidekiq::Testing.fake! do
        expect do
          post :create
        end.to change(BackupWorker.jobs, :size).by(1)
      end
    end
  end
end
