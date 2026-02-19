# frozen_string_literal: true

class CreateTermsOfServices < ActiveRecord::Migration[7.2]
  def change
    create_table :terms_of_services do |t|
      t.text :text, null: false, default: ''
      t.text :changelog, null: false, default: ''
      t.datetime :published_at
      t.datetime :notification_sent_at

      t.timestamps
    end
  end
end
