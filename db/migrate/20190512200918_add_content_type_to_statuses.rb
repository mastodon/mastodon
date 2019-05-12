class AddContentTypeToStatuses < ActiveRecord::Migration[5.2]
  def change
    add_column :statuses, :content_type, :string
  end
end
