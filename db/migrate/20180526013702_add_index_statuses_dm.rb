class AddIndexStatusesDm < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!
  
  def change
    add_index :statuses, [:id, :updated_at], where: 'visibility = 3', algorithm: :concurrently, name: 'index_statuses_dm'
  end
end
