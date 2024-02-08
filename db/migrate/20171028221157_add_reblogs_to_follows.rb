# frozen_string_literal: true

class AddReblogsToFollows < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      add_column :follows, :show_reblogs, :boolean, default: true, null: false
      add_column :follow_requests, :show_reblogs, :boolean, default: true, null: false
    end
  end

  def down
    remove_column :follows, :show_reblogs
    remove_column :follow_requests, :show_reblogs
  end
end
