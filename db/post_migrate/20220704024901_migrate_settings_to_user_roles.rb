# frozen_string_literal: true

class MigrateSettingsToUserRoles < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  class UserRole < ApplicationRecord
    EVERYONE_ROLE_ID = -99
  end

  def up
    process_role_everyone
    process_role_owner
    process_role_admin
    process_role_moderator
  end

  def down; end

  private

  def process_role_everyone
    everyone_role = UserRole.find_by(id: UserRole::EVERYONE_ROLE_ID)
    return unless everyone_role

    everyone_role.permissions &= ~::UserRole::FLAGS[:invite_users] unless min_invite_role == 'user'
    everyone_role.save
  end

  def process_role_owner
    owner_role = UserRole.find_by(name: 'Owner')
    return unless owner_role

    owner_role.highlighted = show_staff_badge
    owner_role.save
  end

  def process_role_admin
    admin_role = UserRole.find_by(name: 'Admin')
    return unless admin_role

    admin_role.permissions |= ::UserRole::FLAGS[:invite_users] if %w(admin moderator).include?(min_invite_role)
    admin_role.highlighted  = show_staff_badge
    admin_role.save
  end

  def process_role_moderator
    moderator_role = UserRole.find_by(name: 'Moderator')
    return unless moderator_role

    moderator_role.permissions |= ::UserRole::FLAGS[:invite_users] if %w(moderator).include?(min_invite_role)
    moderator_role.highlighted  = show_staff_badge
    moderator_role.save
  end

  def min_invite_role
    Setting.min_invite_role
  end

  def show_staff_badge
    Setting.show_staff_badge
  end
end
