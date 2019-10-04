class AddCategoryIdToCustomEmojis < ActiveRecord::Migration[5.2]
  def change
    add_column :custom_emojis, :category_id, :bigint
  end
end
