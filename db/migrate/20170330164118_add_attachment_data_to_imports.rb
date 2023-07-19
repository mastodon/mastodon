# frozen_string_literal: true

class AddAttachmentDataToImports < ActiveRecord::Migration[4.2]
  def self.up
    change_table :imports do |t|
      t.attachment :data
    end
  end

  def self.down
    remove_attachment :imports, :data
  end
end
