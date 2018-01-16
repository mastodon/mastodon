class AddLicenseToStatuses < ActiveRecord::Migration[5.1]
  def change
    add_column :statuses, :license_url, :text, null: true
  end
end
