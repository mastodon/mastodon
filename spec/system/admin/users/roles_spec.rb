# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Users Roles' do
  let(:current_role) { UserRole.create(name: 'Foo', permissions: UserRole::FLAGS[:manage_roles], position: 10) }
  let(:current_user) { Fabricate(:user, role: current_role) }

  let(:previous_role) { nil }
  let(:user) { Fabricate(:user, role: previous_role) }

  before do
    sign_in current_user, scope: :user
  end

  describe 'Managing user roles' do
    let!(:too_high_role) { UserRole.create(name: 'TooHigh', permissions: UserRole::FLAGS[:administrator], position: 100) }
    let!(:usable_role) { UserRole.create(name: 'Usable', permissions: UserRole::FLAGS[:manage_roles], position: 1) }

    it 'selects and updates user roles' do
      visit admin_user_role_path(user)
      expect(page)
        .to have_title I18n.t('admin.accounts.change_role.title', username: user.account.username)

      # Fails to assign not allowed role
      select too_high_role.name, from: 'user_role_id'
      expect { click_on submit_button }
        .to_not(change { user.reload.role_id })
      expect(page)
        .to have_title I18n.t('admin.accounts.change_role.title', username: user.account.username)

      # Assigns allowed role
      select usable_role.name, from: 'user_role_id'
      expect { click_on submit_button }
        .to(change { user.reload.role_id }.to(usable_role.id))
    end
  end
end
