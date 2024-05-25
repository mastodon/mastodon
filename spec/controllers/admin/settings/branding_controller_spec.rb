# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Settings::BrandingController do
  render_views

  describe 'When signed in as an admin' do
    before do
      sign_in Fabricate(:user, role: UserRole.find_by(name: 'Admin')), scope: :user
    end

    describe 'GET #show' do
      it 'returns http success' do
        get :show

        expect(response).to have_http_status(200)
      end
    end

    describe 'PUT #update' do
      before do
        allow_any_instance_of(Form::AdminSettings).to receive(:valid?).and_return(true)
      end

      around do |example|
        before = Setting.site_short_description
        Setting.site_short_description = nil
        example.run
        Setting.site_short_description = before
        Setting.new_setting_key = nil
      end

      it 'cannot create a setting value for a non-admin key' do
        expect(Setting.new_setting_key).to be_blank

        patch :update, params: { form_admin_settings: { new_setting_key: 'New key value' } }

        expect(response).to redirect_to(admin_settings_branding_path)
        expect(Setting.new_setting_key).to be_nil
      end

      it 'creates a settings value that didnt exist before for eligible key' do
        expect(Setting.site_short_description).to be_blank

        patch :update, params: { form_admin_settings: { site_short_description: 'New key value' } }

        expect(response).to redirect_to(admin_settings_branding_path)
        expect(Setting.site_short_description).to eq 'New key value'
      end
    end
  end
end
