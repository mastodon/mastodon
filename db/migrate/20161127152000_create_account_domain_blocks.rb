class CreateAccountDomainBlocks < ActiveRecord::Migration[5.0]
  def change
    create_table :account_domain_blocks do |t|
      t.integer :account_id, null: false
      t.string :domain, null: false, default: ''

      t.timestamps null: false
    end

    add_index :account_domain_blocks, [:account_id, :domain], unique: true
  end
end
