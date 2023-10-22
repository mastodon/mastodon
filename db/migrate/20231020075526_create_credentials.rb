class CreateCredentials < ActiveRecord::Migration[7.0]
  def change
    create_table :credentials do |t|
      t.references  :user, null: false, foreign_key: false
      t.foreign_key :users, on_delete: :cascade
      t.string      :external_id
      t.string      :public_key
      t.bigint      :sign_count
      t.timestamps
    end
    add_index :credentials, :external_id, unique: true
  end
end

