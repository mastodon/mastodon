# frozen_string_literal: true

class AddTrendableToStatuses < ActiveRecord::Migration[6.1]
  def change
    add_column :statuses, :trendable, :boolean # rubocop:disable Rails/ThreeStateBooleanColumn
  end
end
