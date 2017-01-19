class CreateAccountDomainBlocks < ActiveRecord::Migration[5.0]
  def change
    create_table :account_domain_blocks do |t|
      t.integer :account_id, null: false
      t.string :target_domain, null: false

      t.timestamps
    end

    add_index :account_domain_blocks, [:account_id, :target_domain], unique: true
  end
end
