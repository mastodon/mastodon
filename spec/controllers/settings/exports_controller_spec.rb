# frozen_string_literal: true

require 'rails_helper'

describe Settings::ExportsController do
  render_views

  describe 'GET #show' do
    context 'when signed in' do
      let(:user) { Fabricate(:user) }

      before do
        sign_in user, scope: :user
      end

      it 'returns http success with private cache control headers', :aggregate_failures do
        get :show

        expect(response)
          .to have_http_status(200)
          .and render_template(:show)
          .and have_attributes(
            headers: hash_including(
              'Cache-Control' => include('private, no-store')
            )
          )
      end
    end

    context 'when not signed in' do
      it 'redirects' do
        get :show

        expect(response)
          .to redirect_to '/auth/sign_in'
      end
    end
  end

  describe 'POST #create' do
    before do
      sign_in Fabricate(:user), scope: :user
    end

    it 'queues BackupWorker job and redirects', :sidekiq_fake do
      expect { post :create }
        .to change(BackupWorker.jobs, :size).by(1)

      expect(response)
        .to redirect_to(settings_export_path)
    end
  end
end
