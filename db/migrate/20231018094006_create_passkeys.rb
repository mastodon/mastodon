class CreatePasskeys < ActiveRecord::Migration[7.0]
  def change
    create_table :pkusers do |t|
      t.string :email,              null: false, default: ""

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      # t.integer  :sign_in_count, default: 0, null: false
      # t.datetime :current_sign_in_at
      # t.datetime :last_sign_in_at
      # t.string   :current_sign_in_ip
      # t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at


      t.timestamps null: false
      t.string :webauthn_id, null: false

      t.index :webauthn_id, unique: true
      t.index :email, unique: true
    end

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
