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

      describe 'for a record that doesnt exist' do
        after do
          Setting.new_setting_key = nil
        end

        it 'creates a settings value that didnt exist before' do
          expect(Setting.new_setting_key).to be_nil

          patch :update, params: { id: 'new_setting_key', setting: { value: 'New key value' } }

          expect(response).to redirect_to(admin_settings_path)
          expect(Setting.new_setting_key).to eq 'New key value'
        end
      end

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
