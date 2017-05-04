# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SettingsController, type: :controller do
  render_views

  describe 'When signed in as an admin' do
    before do
      sign_in Fabricate(:user, admin: true), scope: :user
    end

    describe 'GET #edit' do
      it 'returns http success' do
        get :edit

        expect(response).to have_http_status(:success)
      end
    end

    describe 'PUT #update' do
      describe 'for a record that doesnt exist' do
        around do |example|
          before = Setting.site_extended_description
          Setting.site_extended_description = nil
          example.run
          Setting.site_extended_description = before
          Setting.new_setting_key = nil
        end

        it 'cannot create a setting value for a non-admin key' do
          expect(Setting.new_setting_key).to be_blank

          patch :update, params: { new_setting_key: 'New key value' }

          expect(response).to redirect_to(edit_admin_settings_path)
          expect(Setting.new_setting_key).to be_nil
        end

        it 'creates a settings value that didnt exist before for eligible key' do
          expect(Setting.site_extended_description).to be_blank

          patch :update, params: { site_extended_description: 'New key value' }

          expect(response).to redirect_to(edit_admin_settings_path)
          expect(Setting.site_extended_description).to eq 'New key value'
        end
      end

      it 'updates a settings value' do
        Setting.site_title = 'Original'
        patch :update, params: { site_title: 'New title' }

        expect(response).to redirect_to(edit_admin_settings_path)
        expect(Setting.site_title).to eq 'New title'
      end

      it 'typecasts open_registrations to boolean' do
        Setting.open_registrations = false
        patch :update, params: { open_registrations: 'true' }

        expect(response).to redirect_to(edit_admin_settings_path)
        expect(Setting.open_registrations).to eq true
      end
    end
  end
end
