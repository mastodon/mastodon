# frozen_string_literal: true

class CreateScheduledStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :scheduled_statuses do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.belongs_to :account, foreign_key: { on_delete: :cascade }
      t.datetime :scheduled_at, index: true
      t.jsonb :params
    end
  end
end
