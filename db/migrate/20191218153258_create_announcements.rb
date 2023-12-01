# frozen_string_literal: true

class CreateAnnouncements < ActiveRecord::Migration[5.2]
  def change
    create_table :announcements do |t|
      t.text :text, null: false, default: ''

      t.boolean :published, null: false, default: false
      t.boolean :all_day, null: false, default: false

      t.datetime :scheduled_at
      t.datetime :starts_at
      t.datetime :ends_at

      t.timestamps
    end
  end
end
