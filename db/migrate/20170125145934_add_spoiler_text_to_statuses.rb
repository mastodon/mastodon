# frozen_string_literal: true

class AddSpoilerTextToStatuses < ActiveRecord::Migration[5.0]
  def change
    add_column :statuses, :spoiler_text, :text, default: '', null: false
  end
end
