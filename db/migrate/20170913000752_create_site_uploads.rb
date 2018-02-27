class CreateSiteUploads < ActiveRecord::Migration[5.1]
  def change
    create_table :site_uploads do |t|
      t.string :var, default: '', null: false, index: { unique: true }
      t.attachment :file
      t.json :meta
      t.timestamps
    end
  end
end
