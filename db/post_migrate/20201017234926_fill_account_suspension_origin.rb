# frozen_string_literal: true

class FillAccountSuspensionOrigin < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    Account.suspended.where(suspension_origin: nil).in_batches.update_all(suspension_origin: :local)
  end

  def down; end
end
