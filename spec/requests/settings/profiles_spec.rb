# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings Profiles' do
  describe 'PUT /settings/profile' do
    before { sign_in Fabricate(:user) }

    it 'gracefully handles invalid nested params' do
      put settings_profile_path(account: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end
end
