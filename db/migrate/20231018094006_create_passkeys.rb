class CreatePasskeys < ActiveRecord::Migration[7.0]
  def change


    create_table :passkeys do |t|
      t.references :pkuser, null: false, foreign_key: true
      t.string :label
      t.string :external_id, index: {unique: true }
      t.string :public_key, index: {unique: true }
      t.integer :sign_count
      t.datetime :last_used_at

      t.timestamps
    end



    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true

  end
end
