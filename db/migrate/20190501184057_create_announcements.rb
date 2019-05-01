class CreateAnnouncements < ActiveRecord::Migration[5.2]
  def change
    create_table :announcements do |t|
      t.string :body, null: false, default: ''
      t.integer :order, null: false, default: 0
      t.timestamps
    end
  end
end
