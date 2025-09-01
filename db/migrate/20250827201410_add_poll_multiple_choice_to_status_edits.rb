# frozen_string_literal: true

class AddPollMultipleChoiceToStatusEdits < ActiveRecord::Migration[8.0]
  def change
    add_column :status_edits, :poll_multiple_choice, :boolean, default: false, null: false
  end
end
