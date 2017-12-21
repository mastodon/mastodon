class AddLicenseToStatuses < ActiveRecord::Migration[5.1]
  def change
    add_column :statuses, :license, :text, null: true
  end
end
