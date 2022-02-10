class AddContentTypeToStatusEdits < ActiveRecord::Migration[6.1]
  def change
    add_column :status_edits, :content_type, :string
  end
end
