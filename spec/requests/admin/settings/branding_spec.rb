# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Settings Branding' do
  describe 'When signed in as an admin' do
    before { sign_in Fabricate(:admin_user) }

    describe 'PUT /admin/settings/branding' do
      it 'cannot create a setting value for a non-admin key' do
        expect { put admin_settings_branding_path, params: { form_admin_settings: { new_setting_key: 'New key value' } } }
          .to_not change(Setting, :new_setting_key).from(nil)

        expect(response)
          .to have_http_status(400)
      end
    end
  end
end
