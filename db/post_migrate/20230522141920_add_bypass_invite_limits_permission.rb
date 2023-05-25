# frozen_string_literal: true

class AddBypassInviteLimitsPermission < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  class UserRole < ApplicationRecord
    FLAGS = {
      bypass_invite_limits: (1 << 20),
    }.freeze
  end

  def change
    admin_role     = UserRole.find_by(name: 'Admin')
    moderator_role = UserRole.find_by(name: 'Moderator')

    if admin_role
      admin_role.permissions |= UserRole::FLAGS[:bypass_invite_limits]
      admin_role.save
    end

    return unless moderator_role

    moderator_role.permissions |= UserRole::FLAGS[:bypass_invite_limits]
    moderator_role.save
  end
end
