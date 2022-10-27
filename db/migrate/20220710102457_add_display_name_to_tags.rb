class AddDisplayNameToTags < ActiveRecord::Migration[6.1]
  def change
    add_column :tags, :display_name, :string
  end
end
