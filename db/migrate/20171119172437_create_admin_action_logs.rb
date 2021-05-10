class CreateAdminActionLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :admin_action_logs do |t|
      t.belongs_to :account, foreign_key: { on_delete: :cascade }
      t.string :action, null: false, default: ''
      t.references :target, polymorphic: true, index: { name: 'index_admin_action_logs_on_target_type_and_target_id' }
      t.text :recorded_changes, null: false, default: ''

      t.timestamps
    end
  end
end
