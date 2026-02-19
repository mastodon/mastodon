# frozen_string_literal: true

class AddOrderedMediaAttachmentIdsToStatusEdits < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      change_table(:status_edits, bulk: true) do |t|
        t.column :ordered_media_attachment_ids, :bigint, array: true
        t.column :media_descriptions, :text, array: true
        t.column :poll_options, :string, array: true
        t.column :sensitive, :boolean # rubocop:disable Rails/ThreeStateBooleanColumn
      end
    end
  end
end
