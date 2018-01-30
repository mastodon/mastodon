class CreateAnnouncements < ActiveRecord::Migration[5.1]
  def change
    if ActiveRecord::Base.connection.table_exists? 'announcements'
      drop_table :announcements
    end
    create_table :announcements do |t|
      t.string :body, null: false, default: ''
      t.integer :order, null: false, default: 0
      t.timestamps
    end
  end
end
