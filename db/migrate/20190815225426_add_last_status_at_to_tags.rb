# frozen_string_literal: true

class AddLastStatusAtToTags < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      change_table(:tags, bulk: true) do |t|
        t.column :last_status_at, :datetime
        t.column :last_trend_at, :datetime
      end
    end
  end
end
