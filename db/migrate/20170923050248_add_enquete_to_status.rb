class AddEnqueteToStatus < ActiveRecord::Migration[5.1]
  def change
    add_column :statuses, :enquete, :json
  end
end
