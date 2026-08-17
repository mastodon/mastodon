# frozen_string_literal: true

class MigrateRoles < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  class UserRole < ApplicationRecord; end
  class User < ApplicationRecord; end

  def up
    create_user_roles

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

  private

  def create_user_roles
    now = Time.zone.now.to_fs(:db)

    safety_assured do
      execute <<~SQL.squish
        INSERT INTO user_roles ( id, permissions, created_at, updated_at )
        VALUES ( -99, 65536, '#{now}', '#{now}' )
        ON CONFLICT DO NOTHING
      SQL

      [
        ['Moderator', 10, 1308],
        ['Admin', 100, 983_036],
        ['Owner', 1000, 1],
      ].each do |name, position, permissions|
        execute <<~SQL.squish
          INSERT INTO user_roles ( name, position, highlighted, permissions, created_at, updated_at )
          SELECT '#{name}', #{position}, true, #{permissions}, '#{now}', '#{now}'
          WHERE NOT EXISTS ( SELECT 1 FROM user_roles WHERE name = '#{name}' )
        SQL
      end
    end
  end
end
