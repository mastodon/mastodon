# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Settings About' do
  describe 'PUT /admin/settings/about' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      put admin_settings_about_path(form_admin_settings: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end
end
