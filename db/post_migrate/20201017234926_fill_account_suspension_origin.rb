# frozen_string_literal: true

class FillAccountSuspensionOrigin < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  class MigrationAccount < ApplicationRecord
    self.table_name = :accounts
    scope :suspended, -> { where.not(suspended_at: nil) }
    enum :suspension_origin, { local: 0, remote: 1 }, prefix: true
  end

  def up
    MigrationAccount.reset_column_information
    MigrationAccount.suspended.where(suspension_origin: nil).in_batches.update_all(suspension_origin: :local)
  end

  def down; end
end
