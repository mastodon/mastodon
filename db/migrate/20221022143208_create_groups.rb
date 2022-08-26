class CreateGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :groups do |t|
      t.string :domain, null: true
      t.string :url
      t.text :note, default: '', null: false
      t.string :display_name, default: '', null: false
      t.boolean :locked, null: false, default: false
      t.boolean :hide_members, null: false, default: false
      t.datetime :suspended_at
      t.integer :suspension_origin
      t.boolean :discoverable

      # Attachments
      t.attachment :avatar
      t.string :avatar_remote_url, default: '', null: false
      t.attachment :header
      t.string :header_remote_url, default: '', null: false
      t.integer :image_storage_schema_version

      # Protocol URLs
      t.string :uri
      t.string :outbox_url, default: '', null: false
      t.string :inbox_url, default: '', null: false
      t.string :shared_inbox_url, null: false, default: ''
      t.string :members_url, default: '', null: false
      t.string :wall_url, default: '', null: false

      # RSA key pair
      t.text :private_key, null: true
      t.text :public_key, null: false, default: ''

      t.timestamps
    end

    add_index :groups, :uri, unique: true, opclass: :text_pattern_ops, where: '(uri IS NOT NULL)'
  end
end
