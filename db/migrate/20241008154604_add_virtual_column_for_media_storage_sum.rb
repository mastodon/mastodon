# frozen_string_literal: true

class AddVirtualColumnForMediaStorageSum < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      change_table :media_attachments do |t|
        t.virtual :combined_file_size, type: :integer, as: combined_file_size, stored: true
      end
    end
  end

  private

  def combined_file_size
    <<~SQL.squish
      COALESCE(file_file_size, 0) + COALESCE(thumbnail_file_size, 0)
    SQL
  end
end
