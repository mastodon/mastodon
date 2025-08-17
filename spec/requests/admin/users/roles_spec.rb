# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Users Roles' do
  context 'when target user is higher ranked than current user' do
    let(:current_role) { UserRole.create(name: 'Foo', permissions: UserRole::FLAGS[:manage_roles], position: 10) }
    let(:current_user) { Fabricate(:user, role: current_role) }

    let(:previous_role) { UserRole.create(name: 'Baz', permissions: UserRole::FLAGS[:administrator], position: 100) }
    let(:user) { Fabricate(:user, role: previous_role) }

    before { sign_in(current_user) }

    describe 'GET /admin/users/:user_id/role' do
      it 'returns http forbidden' do
        get admin_user_role_path(user.id)

        expect(response)
          .to have_http_status(403)
      end
    end

    describe 'PUT /admin/users/:user_id/role' do
      it 'returns http forbidden' do
        put admin_user_role_path(user.id)

        expect(response)
          .to have_http_status(403)
      end
    end
  end

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
