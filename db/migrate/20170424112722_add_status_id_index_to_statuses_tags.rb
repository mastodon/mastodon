# frozen_string_literal: true

class AddStatusIdIndexToStatusesTags < ActiveRecord::Migration[5.0]
  def change
    add_index :statuses_tags, :status_id
  end
end
