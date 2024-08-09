# frozen_string_literal: true

class PopulateEveryoneRole < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  class UserRole < ApplicationRecord
    EVERYONE_ROLE_ID = -99

    FLAGS = {
      invite_users: (1 << 16),
    }.freeze
  end

  def up
    UserRole.create!(id: UserRole::EVERYONE_ROLE_ID, permissions: UserRole::FLAGS[:invite_users])
  rescue ActiveRecord::RecordNotUnique
    nil
  end

  def down; end
end
