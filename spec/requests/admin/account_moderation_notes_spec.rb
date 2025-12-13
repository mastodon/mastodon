# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Account Moderation Notes' do
  describe 'POST /admin/account_moderation_notes' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post admin_account_moderation_notes_path(account_moderation_note: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end
end
