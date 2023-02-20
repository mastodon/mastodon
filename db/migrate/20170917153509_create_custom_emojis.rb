class CreateCustomEmojis < ActiveRecord::Migration[5.1]
  def change
    create_table :custom_emojis do |t|
      t.string :shortcode, null: false, default: ''
      t.string :domain
      t.attachment :image

      t.timestamps
    end

    add_index :custom_emojis, %i(shortcode domain), unique: true
  end
end
