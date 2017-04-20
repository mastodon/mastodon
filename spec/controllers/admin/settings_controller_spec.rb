require 'rails_helper'

RSpec.describe Admin::SettingsController, type: :controller do
  render_views

  describe 'When signed in as an admin' do
    before do
      sign_in Fabricate(:user, admin: true), scope: :user
    end

    describe 'GET #index' do
      it 'returns http success' do
        get :index

        expect(response).to have_http_status(:success)
      end
    end

    describe 'PUT #update' do
      it 'updates a settings value' do
        Setting.site_title = 'Original'
        patch :update, params: { id: 'site_title', setting: { value: 'New title' } }

        expect(response).to redirect_to(admin_settings_path)
        expect(Setting.site_title).to eq 'New title'
      end

      it 'typecasts open_registrations to boolean' do
        Setting.open_registrations = false
        patch :update, params: { id: 'open_registrations', setting: { value: 'true' } }

        expect(response).to redirect_to(admin_settings_path)
        expect(Setting.open_registrations).to eq true
      end
    end
  end
end
