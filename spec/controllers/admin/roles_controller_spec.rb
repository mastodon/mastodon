# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::RolesController do
  render_views

  let(:permissions)  { UserRole::Flags::NONE }
  let(:current_role) { UserRole.create(name: 'Foo', permissions: permissions, position: 10) }
  let(:current_user) { Fabricate(:user, role: current_role) }

  before do
    sign_in current_user, scope: :user
  end

  describe 'POST #create' do
    let(:selected_position) { 1 }
    let(:selected_permissions_as_keys) { %w(manage_roles) }

    before do
      post :create, params: { user_role: { name: 'Bar', position: selected_position, permissions_as_keys: selected_permissions_as_keys } }
    end

    context 'when user has permission to manage roles' do
      let(:permissions) { UserRole::FLAGS[:manage_roles] }

      context 'when new role has permissions the user does not have' do
        let(:selected_position) { 1 }
        let(:selected_permissions_as_keys) { %w(manage_roles manage_users manage_reports) }

        it 'renders new template and does not create role' do
          expect(response).to render_template(:new)

          expect(UserRole.find_by(name: 'Bar')).to be_nil
        end
      end

      context 'when user has administrator permission' do
        let(:permissions) { UserRole::FLAGS[:administrator] }

        let(:selected_position) { 1 }
        let(:selected_permissions_as_keys) { %w(manage_roles manage_users manage_reports) }

        it 'redirects to roles page and creates new role' do
          expect(response).to redirect_to(admin_roles_path)

          expect(UserRole.find_by(name: 'Bar')).to_not be_nil
        end
      end
    end
  end

  describe 'PUT #update' do
    let(:role_position) { 8 }
    let(:role_permissions) { UserRole::FLAGS[:manage_users] }
    let(:role) { UserRole.create(name: 'Bar', permissions: role_permissions, position: role_position) }

    let(:selected_position) { 8 }
    let(:selected_permissions_as_keys) { %w(manage_users) }

    before do
      put :update, params: { id: role.id, user_role: { name: 'Baz', position: selected_position, permissions_as_keys: selected_permissions_as_keys } }
    end

    context 'when user has permission to manage roles' do
      let(:permissions) { UserRole::FLAGS[:manage_roles] }

      context 'when role has permissions the user doesn\'t' do
        it 'renders edit template and does not update role' do
          expect(response).to render_template(:edit)

          expect(role.reload.name).to eq 'Bar'
        end
      end
    end
  end
end
