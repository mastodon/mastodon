# frozen_string_literal: true

class UpdateStatusesIndex < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured { add_index :statuses, [:account_id, :id, :visibility, :updated_at], where: 'deleted_at IS NULL', order: { id: :desc }, algorithm: :concurrently, name: :index_statuses_20190820 }
    remove_index :statuses, name: :index_statuses_20180106
  end

  def down
    safety_assured { add_index :statuses, [:account_id, :id, :visibility, :updated_at], order: { id: :desc }, algorithm: :concurrently, name: :index_statuses_20180106 }
    remove_index :statuses, name: :index_statuses_20190820
  end
end
