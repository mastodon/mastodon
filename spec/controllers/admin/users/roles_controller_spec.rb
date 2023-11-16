# frozen_string_literal: true

require 'rails_helper'

describe Admin::Users::RolesController do
  render_views

  let(:current_role) { UserRole.create(name: 'Foo', permissions: UserRole::FLAGS[:manage_roles], position: 10) }
  let(:current_user) { Fabricate(:user, role: current_role) }

  let(:previous_role) { nil }
  let(:user) { Fabricate(:user, role: previous_role) }

  before do
    sign_in current_user, scope: :user
  end

  describe 'GET #show' do
    before do
      get :show, params: { user_id: user.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    context 'when target user is higher ranked than current user' do
      let(:previous_role) { UserRole.create(name: 'Baz', permissions: UserRole::FLAGS[:administrator], position: 100) }

      it 'returns http forbidden' do
        expect(response).to have_http_status(403)
      end
    end
  end

  describe 'PUT #update' do
    let(:selected_role) { UserRole.create(name: 'Bar', permissions: permissions, position: position) }

    before do
      put :update, params: { user_id: user.id, user: { role_id: selected_role.id } }
    end

    context 'with manage roles permissions' do
      let(:permissions) { UserRole::FLAGS[:manage_roles] }
      let(:position) { 1 }

      it 'updates user role and redirects back to account page' do
        expect(user.reload)
          .to have_attributes(
            role_id: eq(selected_role&.id)
          )

        expect(response)
          .to redirect_to(admin_account_path(user.account_id))
      end
    end

    context 'when selected role has higher position than current user\'s role' do
      let(:permissions) { UserRole::FLAGS[:administrator] }
      let(:position) { 100 }

      it 'does not update user role' do
        expect(user.reload)
          .to have_attributes(
            role_id: eq(previous_role&.id)
          )

        expect(response)
          .to have_http_status(200)
          .and render_template(:show)
      end
    end

    context 'when target user is higher ranked than current user' do
      let(:previous_role) { UserRole.create(name: 'Baz', permissions: UserRole::FLAGS[:administrator], position: 100) }
      let(:permissions) { UserRole::FLAGS[:manage_roles] }
      let(:position) { 1 }

      it 'does not update user role and return forbidden' do
        expect(user.reload)
          .to have_attributes(
            role_id: eq(previous_role&.id)
          )

        expect(response)
          .to have_http_status(403)
      end
    end
  end
end
