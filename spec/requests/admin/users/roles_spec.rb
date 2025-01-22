# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Users Roles' do
  describe 'PUT /admin/users/:user_id/role' do
    before { sign_in Fabricate(:admin_user) }

    let(:user) { Fabricate :user }

    it 'gracefully handles invalid nested params' do
      put admin_user_role_path(user.id, user: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end
end
