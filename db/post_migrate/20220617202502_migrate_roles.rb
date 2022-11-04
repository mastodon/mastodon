# frozen_string_literal: true

class MigrateRoles < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  class UserRole < ApplicationRecord; end
  class User < ApplicationRecord; end

  def up
    load Rails.root.join('db', 'seeds', '03_roles.rb')

    owner_role     = UserRole.find_by(name: 'Owner')
    moderator_role = UserRole.find_by(name: 'Moderator')

    User.where(admin: true).in_batches.update_all(role_id: owner_role.id)
    User.where(moderator: true).in_batches.update_all(role_id: moderator_role.id)
  end

  def down
    admin_role     = UserRole.find_by(name: 'Admin')
    owner_role     = UserRole.find_by(name: 'Owner')
    moderator_role = UserRole.find_by(name: 'Moderator')

    User.where(role_id: [admin_role.id, owner_role.id]).in_batches.update_all(admin: true) if admin_role
    User.where(role_id: moderator_role.id).in_batches.update_all(moderator: true) if moderator_role
  end
end
