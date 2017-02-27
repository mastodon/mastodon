class AddWhitelists < ActiveRecord::Migration[5.0]
  def change
    create_table :domain_whitelists do |t|
      t.string :domain, null: false, default: ''
      t.integer :severity, default: 0
      t.boolean :reject_media
      t.timestamps
    end

    add_index :domain_whitelists, :domain, unique: true
  end
end
