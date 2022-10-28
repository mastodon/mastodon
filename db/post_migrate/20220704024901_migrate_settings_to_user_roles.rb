# frozen_string_literal: true

class MigrateSettingsToUserRoles < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  class UserRole < ApplicationRecord; end

  def up
    owner_role     = UserRole.find_by(name: 'Owner')
    admin_role     = UserRole.find_by(name: 'Admin')
    moderator_role = UserRole.find_by(name: 'Moderator')
    everyone_role  = UserRole.find_by(id: -99)

    min_invite_role  = Setting.min_invite_role
    show_staff_badge = Setting.show_staff_badge

    if everyone_role
      everyone_role.permissions &= ~::UserRole::FLAGS[:invite_users] unless min_invite_role == 'user'
      everyone_role.save
    end

    if owner_role
      owner_role.highlighted = show_staff_badge
      owner_role.save
    end

    if admin_role
      admin_role.permissions |= ::UserRole::FLAGS[:invite_users] if %w(admin moderator).include?(min_invite_role)
      admin_role.highlighted  = show_staff_badge
      admin_role.save
    end

    if moderator_role
      moderator_role.permissions |= ::UserRole::FLAGS[:invite_users] if %w(moderator).include?(min_invite_role)
      moderator_role.highlighted  = show_staff_badge
      moderator_role.save
    end
  end

  def down; end
end
