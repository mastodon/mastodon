class AddActivityPubTypeToStatuses < ActiveRecord::Migration[5.2]
  def change
    add_column :statuses, :activity_pub_type, :string
  end
end
