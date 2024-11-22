# frozen_string_literal: true

class AddNotifyToFollows < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      add_column :follows, :notify, :boolean, default: false, null: false
      add_column :follow_requests, :notify, :boolean, default: false, null: false
    end
  end

  def down
    remove_column :follows, :notify
    remove_column :follow_requests, :notify
  end
end
