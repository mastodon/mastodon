class AddLicenseToStatuses < ActiveRecord::Migration[5.1]
  def change
    add_column :statuses, :license_url, :string, null: true
  end
end
