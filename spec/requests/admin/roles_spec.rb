# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Roles' do
  context 'when signed in as lower permissions user' do
    before { sign_in Fabricate(:user, role: Fabricate(:user_role, permissions: UserRole::Flags::NONE)) }

    describe 'GET /admin/roles' do
      it 'returns http forbidden' do
        get admin_roles_path

        expect(response)
          .to have_http_status(403)
      end
    end

    describe 'GET /admin/roles/new' do
      it 'returns http forbidden' do
        get new_admin_role_path

        expect(response)
          .to have_http_status(403)
      end
    end

    describe 'GET /admin/roles/:id/edit' do
      let(:role) { Fabricate :user_role }

      it 'returns http forbidden' do
        get edit_admin_role_path(role)

        expect(response)
          .to have_http_status(403)
      end
    end

    describe 'PUT /admin/roles/:id' do
      let(:role) { Fabricate :user_role }

      it 'returns http forbidden' do
        put admin_role_path(role)

        expect(response)
          .to have_http_status(403)
      end
    end

    describe 'DELETE /admin/roles/:id' do
      let(:role) { Fabricate :user_role }

      it 'returns http forbidden' do
        delete admin_role_path(role)

        expect(response)
          .to have_http_status(403)
      end
    end
  end

  context 'when signed in as admin' do
    before { sign_in Fabricate(:admin_user) }

    describe 'POST /admin/roles' do
      it 'gracefully handles invalid nested params' do
        post admin_roles_path(user_role: 'invalid')

        expect(response)
          .to have_http_status(400)
      end
    end
  end
end
