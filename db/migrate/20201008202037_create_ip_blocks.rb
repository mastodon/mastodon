class CreateIpBlocks < ActiveRecord::Migration[5.2]
  def change
    create_table :ip_blocks do |t|
      t.inet :ip, null: false, default: '0.0.0.0'
      t.integer :severity, null: false, default: 0
      t.datetime :expires_at
      t.text :comment, null: false, default: ''

      t.timestamps
    end
  end
end
