# frozen_string_literal: true

class CreatePollVotes < ActiveRecord::Migration[5.2]
  def change
    create_table :poll_votes do |t|
      t.belongs_to :account, foreign_key: { on_delete: :cascade }
      t.belongs_to :poll, foreign_key: { on_delete: :cascade }
      t.integer :choice, null: false, default: 0

      t.timestamps
    end
  end
end
