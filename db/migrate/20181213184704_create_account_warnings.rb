class CreateAccountWarnings < ActiveRecord::Migration[5.2]
  def change
    create_table :account_warnings do |t|
      t.belongs_to :account, foreign_key: { on_delete: :nullify }
      t.belongs_to :target_account, foreign_key: { to_table: 'accounts', on_delete: :cascade }
      t.integer :action, null: false, default: 0
      t.text :text, null: false, default: ''

      t.timestamps
    end
  end
end
