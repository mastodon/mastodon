# frozen_string_literal: true

class RemoveScoreFromTags < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured do
      remove_column :tags, :score, :int
      remove_column :tags, :last_trend_at, :datetime
    end
  end
end
