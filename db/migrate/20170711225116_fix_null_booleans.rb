# frozen_string_literal: true

class FixNullBooleans < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      change_column_default :domain_blocks, :reject_media, false # rubocop:disable Rails/ReversibleMigration
      change_column_null :domain_blocks, :reject_media, false, false

      change_column_default :imports, :approved, false # rubocop:disable Rails/ReversibleMigration
      change_column_null :imports, :approved, false, false

      change_column_null :statuses, :sensitive, false, false
      change_column_null :statuses, :reply, false, false

      change_column_null :users, :admin, false, false

      change_column_default :users, :otp_required_for_login, false # rubocop:disable Rails/ReversibleMigration
      change_column_null :users, :otp_required_for_login, false, false
    end
  end
end
