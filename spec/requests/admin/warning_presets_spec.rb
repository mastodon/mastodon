# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Warning Presets' do
  describe 'POST /admin/warning_presets' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post admin_warning_presets_path(account_warning_preset: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end
end
