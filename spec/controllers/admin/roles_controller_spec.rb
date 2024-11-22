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

  describe 'GET #index' do
    before do
      get :index
    end

    context 'when user does not have permission to manage roles' do
      it 'returns http forbidden' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when user has permission to manage roles' do
      let(:permissions) { UserRole::FLAGS[:manage_roles] }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET #new' do
    before do
      get :new
    end

    context 'when user does not have permission to manage roles' do
      it 'returns http forbidden' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when user has permission to manage roles' do
      let(:permissions) { UserRole::FLAGS[:manage_roles] }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'POST #create' do
    let(:selected_position) { 1 }
    let(:selected_permissions_as_keys) { %w(manage_roles) }

    before do
      post :create, params: { user_role: { name: 'Bar', position: selected_position, permissions_as_keys: selected_permissions_as_keys } }
    end

    context 'when user has permission to manage roles' do
      let(:permissions) { UserRole::FLAGS[:manage_roles] }

      context 'when new role\'s does not elevate above the user\'s role' do
        let(:selected_position) { 1 }
        let(:selected_permissions_as_keys) { %w(manage_roles) }

        it 'redirects to roles page' do
          expect(response).to redirect_to(admin_roles_path)
        end

        it 'creates new role' do
          expect(UserRole.find_by(name: 'Bar')).to_not be_nil
        end
      end

      context 'when new role\'s position is higher than user\'s role' do
        let(:selected_position) { 100 }
        let(:selected_permissions_as_keys) { %w(manage_roles) }

        it 'renders new template' do
          expect(response).to render_template(:new)
        end

        it 'does not create new role' do
          expect(UserRole.find_by(name: 'Bar')).to be_nil
        end
      end

      context 'when new role has permissions the user does not have' do
        let(:selected_position) { 1 }
        let(:selected_permissions_as_keys) { %w(manage_roles manage_users manage_reports) }

        it 'renders new template' do
          expect(response).to render_template(:new)
        end

        it 'does not create new role' do
          expect(UserRole.find_by(name: 'Bar')).to be_nil
        end
      end

      context 'when user has administrator permission' do
        let(:permissions) { UserRole::FLAGS[:administrator] }

        let(:selected_position) { 1 }
        let(:selected_permissions_as_keys) { %w(manage_roles manage_users manage_reports) }

        it 'redirects to roles page' do
          expect(response).to redirect_to(admin_roles_path)
        end

        it 'creates new role' do
          expect(UserRole.find_by(name: 'Bar')).to_not be_nil
        end
      end
    end
  end

  describe 'GET #edit' do
    let(:role_position) { 8 }
    let(:role) { UserRole.create(name: 'Bar', permissions: UserRole::FLAGS[:manage_users], position: role_position) }

    before do
      get :edit, params: { id: role.id }
    end

    context 'when user does not have permission to manage roles' do
      it 'returns http forbidden' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when user has permission to manage roles' do
      let(:permissions) { UserRole::FLAGS[:manage_roles] }

      context 'when user outranks the role' do
        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'when role outranks user' do
        let(:role_position) { current_role.position + 1 }

        it 'returns http forbidden' do
          expect(response).to have_http_status(403)
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

    context 'when user does not have permission to manage roles' do
      it 'returns http forbidden' do
        expect(response).to have_http_status(403)
      end

      it 'does not update the role' do
        expect(role.reload.name).to eq 'Bar'
      end
    end

    context 'when user has permission to manage roles' do
      let(:permissions) { UserRole::FLAGS[:manage_roles] }

      context 'when role has permissions the user doesn\'t' do
        it 'renders edit template' do
          expect(response).to render_template(:edit)
        end

        it 'does not update the role' do
          expect(role.reload.name).to eq 'Bar'
        end
      end

      context 'when user has all permissions of the role' do
        let(:permissions) { UserRole::FLAGS[:manage_roles] | UserRole::FLAGS[:manage_users] }

        context 'when user outranks the role' do
          it 'redirects to roles page' do
            expect(response).to redirect_to(admin_roles_path)
          end

          it 'updates the role' do
            expect(role.reload.name).to eq 'Baz'
          end
        end

        context 'when role outranks user' do
          let(:role_position) { current_role.position + 1 }

          it 'returns http forbidden' do
            expect(response).to have_http_status(403)
          end

          it 'does not update the role' do
            expect(role.reload.name).to eq 'Bar'
          end
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:role_position) { 8 }
    let(:role) { UserRole.create(name: 'Bar', permissions: UserRole::FLAGS[:manage_users], position: role_position) }

    before do
      delete :destroy, params: { id: role.id }
    end

    context 'when user does not have permission to manage roles' do
      it 'returns http forbidden' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when user has permission to manage roles' do
      let(:permissions) { UserRole::FLAGS[:manage_roles] }

      context 'when user outranks the role' do
        it 'redirects to roles page' do
          expect(response).to redirect_to(admin_roles_path)
        end
      end

      context 'when role outranks user' do
        let(:role_position) { current_role.position + 1 }

        it 'returns http forbidden' do
          expect(response).to have_http_status(403)
        end
      end
    end
  end
end
