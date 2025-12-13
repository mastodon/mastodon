# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Announcements' do
  describe 'POST /admin/announcements' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post admin_announcements_path(announcement: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end
end
