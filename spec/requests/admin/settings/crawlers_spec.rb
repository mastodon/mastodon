# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Settings Crawler Controls' do
  context 'when signed in as an admin' do
    before { sign_in Fabricate(:admin_user) }

    describe 'PUT /admin/settings/crawlers' do
      it 'cannot create a setting value for a non-admin key' do
        expect { put admin_settings_crawlers_path, params: { form_admin_settings: { new_setting_key: 'New key value' } } }
          .to_not change(Setting, :new_setting_key).from(nil)

        expect(response)
          .to have_http_status(400)
      end
    end

    describe 'PUT /admin/settings/crawlers with valid params' do
      let(:request) { put admin_settings_crawlers_path, params: { form_admin_settings: { override_robots: '1' } } }

      it 'saves the value for a valid key' do
        expect { request }.to change(Setting, :override_robots).from(nil).to(true)
        expect(request).to redirect_to(admin_settings_crawlers_path)
        expect(response).to have_http_status(302)
      end
    end
  end
end
