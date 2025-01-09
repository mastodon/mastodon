# frozen_string_literal: true

class AddLastStatusAtToAccountStats < ActiveRecord::Migration[5.2]
  def change
    add_column :account_stats, :last_status_at, :datetime
  end
end
