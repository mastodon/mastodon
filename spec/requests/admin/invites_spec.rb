# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Invites' do
  describe 'POST /admin/invites' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post admin_invites_path(invite: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end
end
