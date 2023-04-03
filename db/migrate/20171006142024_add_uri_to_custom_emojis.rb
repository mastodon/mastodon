class AddUriToCustomEmojis < ActiveRecord::Migration[5.2]
  def change
    add_column :custom_emojis, :uri, :string
    add_column :custom_emojis, :image_remote_url, :string
  end
end
