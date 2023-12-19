# frozen_string_literal: true

class AddMaxScoreToTags < ActiveRecord::Migration[5.2]
  def change
    add_column :tags, :max_score, :float
    add_column :tags, :max_score_at, :datetime
  end
end
