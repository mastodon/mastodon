# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Roles' do
  context 'when user has administrator permissions' do
    let(:user_role) { Fabricate(:user_role, permissions: UserRole::FLAGS[:administrator], position: 10) }

    before { sign_in Fabricate(:user, role: user_role) }

    it 'creates new user role' do
      visit new_admin_role_path

      fill_in 'user_role_name', with: 'Baz'
      fill_in 'user_role_position', with: '1'
      check 'user_role_permissions_as_keys_manage_reports'
      check 'user_role_permissions_as_keys_manage_roles'

      expect { click_on I18n.t('admin.roles.add_new') }
        .to change(UserRole, :count)
      expect(page)
        .to have_title(I18n.t('admin.roles.title'))
    end
  end

  context 'when user has permissions to manage roles' do
    let(:user_role) { Fabricate(:user_role, permissions: UserRole::FLAGS[:manage_roles], position: 10) }

    before { sign_in Fabricate(:user, role: user_role) }

    it 'Creates user roles' do
      visit admin_roles_path
      expect(page)
        .to have_title(I18n.t('admin.roles.title'))

      click_on I18n.t('admin.roles.add_new')
      expect(page)
        .to have_title(I18n.t('admin.roles.add_new'))

      # Position too high
      fill_in 'user_role_name', with: 'Baz'
      fill_in 'user_role_position', with: '100'
      expect { click_on I18n.t('admin.roles.add_new') }
        .to_not change(UserRole, :count)
      expect(page)
        .to have_content(I18n.t('activerecord.errors.models.user_role.attributes.position.elevated'))

      # Valid submission
      fill_in 'user_role_name', with: 'Baz'
      fill_in 'user_role_position', with: '5' # Lower than user
      check 'user_role_permissions_as_keys_manage_roles' # User has permission
      expect { click_on I18n.t('admin.roles.add_new') }
        .to change(UserRole, :count)
      expect(page)
        .to have_title(I18n.t('admin.roles.title'))
    end

    it 'Manages existing user roles' do
      role = Fabricate :user_role, name: 'Baz'

      visit edit_admin_role_path(role)
      expect(page)
        .to have_title(I18n.t('admin.roles.edit', name: 'Baz'))

      # Update role attribute
      fill_in 'user_role_position', with: '5' # Lower than user
      expect { click_on submit_button }
        .to(change { role.reload.position })

      # Destroy the role
      visit edit_admin_role_path(role)
      expect { click_on I18n.t('admin.roles.delete') }
        .to change(UserRole, :count).by(-1)
      expect(page)
        .to have_title(I18n.t('admin.roles.title'))
    end
  end
end
