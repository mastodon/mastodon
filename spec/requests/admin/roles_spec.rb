# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Roles' do
  context 'when signed in as lower permissions user' do
    let(:user_role) { Fabricate(:user_role, permissions: UserRole::Flags::NONE) }

    before { sign_in Fabricate(:user, role: user_role) }

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
      let(:role) { Fabricate(:user_role) }

      it 'returns http forbidden' do
        get edit_admin_role_path(role)

        expect(response)
          .to have_http_status(403)
      end
    end

    describe 'PUT /admin/roles/:id' do
      let(:role) { Fabricate(:user_role) }

      it 'returns http forbidden' do
        put admin_role_path(role)

        expect(response)
          .to have_http_status(403)
      end
    end

    describe 'DELETE /admin/roles/:id' do
      let(:role) { Fabricate(:user_role) }

      it 'returns http forbidden' do
        delete admin_role_path(role)

        expect(response)
          .to have_http_status(403)
      end
    end
  end

  context 'when user has permissions to manage roles' do
    let(:user_role) { Fabricate(:user_role, permissions: UserRole::FLAGS[:manage_users]) }

    before { sign_in Fabricate(:user, role: user_role) }

    context 'when target role permission outranks user' do
      let(:role) { Fabricate(:user_role, position: user_role.position + 1) }

      describe 'GET /admin/roles/:id/edit' do
        it 'returns http forbidden' do
          get edit_admin_role_path(role)

          expect(response)
            .to have_http_status(403)
        end
      end

      describe 'PUT /admin/roles/:id' do
        it 'returns http forbidden' do
          put admin_role_path(role)

          expect(response)
            .to have_http_status(403)
        end
      end

      describe 'DELETE /admin/roles/:id' do
        it 'returns http forbidden' do
          delete admin_role_path(role)

          expect(response)
            .to have_http_status(403)
        end
      end
    end
  end

  context 'when attempting to add permissions the user does not have' do
    let(:user_role) { Fabricate(:user_role, permissions: UserRole::FLAGS[:manage_roles], position: 5) }

    before { sign_in Fabricate(:user, role: user_role) }

    describe 'POST /admin/roles' do
      subject { post admin_roles_path, params: { user_role: { name: 'Bar', position: 2, permissions_as_keys: %w(manage_roles manage_users manage_reports) } } }

      it 'does not create role' do
        expect { subject }
          .to_not change(UserRole, :count)

        expect(response.body)
          .to include(I18n.t('admin.roles.add_new'))
      end
    end

    describe 'PUT /admin/roles/:id' do
      subject { put admin_role_path(role), params: { user_role: { position: 2, permissions_as_keys: %w(manage_roles manage_users manage_reports) } } }

      let(:role) { Fabricate(:user_role, name: 'Bar') }

      it 'does not create role' do
        expect { subject }
          .to_not(change { role.reload.permissions })

        expect(response.parsed_body.title)
          .to match(I18n.t('admin.roles.edit', name: 'Bar'))
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
