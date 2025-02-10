# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Roles' do
  describe 'POST /admin/roles' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post admin_roles_path(user_role: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end
end
