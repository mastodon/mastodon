# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Settings::BrandingController do
  render_views

  describe 'When signed in as an admin' do
    before do
      sign_in Fabricate(:admin_user), scope: :user
    end

    describe 'PUT #update' do
      it 'cannot create a setting value for a non-admin key' do
        expect(Setting.new_setting_key).to be_blank

        patch :update, params: { form_admin_settings: { new_setting_key: 'New key value' } }

        expect(response).to redirect_to(admin_settings_branding_path)
        expect(Setting.new_setting_key).to be_nil
      end
    end
  end
end
