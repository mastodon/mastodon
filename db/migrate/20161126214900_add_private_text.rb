class AddPrivateText < ActiveRecord::Migration
  def change
    add_column :statuses, :private_text, :text, null: false, default: ''
  end
end
