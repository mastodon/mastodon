# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Settings External Discovery' do
  describe 'When signed in as an admin' do
    before { sign_in Fabricate(:admin_user) }

    describe 'PUT /admin/settings/external' do
      it 'cannot create a setting value for a non-admin key' do
        expect { put admin_settings_external_path, params: { form_admin_settings: { new_setting_key: 'New key value' } } }
          .to_not change(Setting, :new_setting_key).from(nil)

        expect(response)
          .to have_http_status(400)
      end
    end

    describe 'PUT /admin/settings/external with valid params' do
      let(:request) { put admin_settings_external_path, params: { form_admin_settings: { activity_api_enabled: 'false' } } }

      it 'saves the value for a valid key' do
        expect { request }.to change(Setting, :activity_api_enabled).from(true)
        expect(request).to redirect_to(admin_settings_external_path)
        expect(response).to have_http_status(302)
      end
    end
  end
end
