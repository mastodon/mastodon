# frozen_string_literal: true

class RemoveMediaAttachmentsChangedFromStatusEdits < ActiveRecord::Migration[5.2]
  def change
    safety_assured { remove_column :status_edits, :media_attachments_changed, :boolean, default: false, null: false }
  end
end
