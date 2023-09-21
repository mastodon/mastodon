# frozen_string_literal: true

class AddVotersCountToPolls < ActiveRecord::Migration[5.2]
  def change
    add_column :polls, :voters_count, :bigint
  end
end
