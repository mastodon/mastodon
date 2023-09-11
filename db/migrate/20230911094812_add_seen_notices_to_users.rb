# frozen_string_literal: true

class AddSeenNoticesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :seen_notices, :bigint
  end
end
