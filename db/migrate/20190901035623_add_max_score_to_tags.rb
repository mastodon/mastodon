# frozen_string_literal: true

class AddMaxScoreToTags < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      change_table(:tags, bulk: true) do |t|
        t.column :max_score, :float
        t.column :max_score_at, :datetime
      end
    end
  end
end
