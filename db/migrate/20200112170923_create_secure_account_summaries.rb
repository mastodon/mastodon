class CreateSecureAccountSummaries < ActiveRecord::Migration[5.2]
  def change
    create_table :secure_account_summaries do |t|
      t.bigint :account_id, index: true
      t.string :encrypted_summary, default: '', null: false
      t.string :encrypted_summary_iv, default: '', null: false, index: { unique: true }

      t.timestamps
    end
  end
end
