# frozen_string_literal: true

class AddNotNullToPollVoteAccountColumn < ActiveRecord::Migration[7.2]
  def change
    add_check_constraint :poll_votes, 'account_id IS NOT NULL', name: 'poll_votes_account_id_null', validate: false
  end
end
