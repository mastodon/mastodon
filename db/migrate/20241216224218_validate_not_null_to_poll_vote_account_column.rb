# frozen_string_literal: true

class ValidateNotNullToPollVoteAccountColumn < ActiveRecord::Migration[7.2]
  def up
    connection.execute(<<~SQL.squish)
      DELETE FROM poll_votes
      WHERE account_id IS NULL
    SQL

    validate_check_constraint :poll_votes, name: 'poll_votes_account_id_null'
    change_column_null :poll_votes, :account_id, false
    remove_check_constraint :poll_votes, name: 'poll_votes_account_id_null'
  end

  def down
    add_check_constraint :poll_votes, 'account_id IS NOT NULL', name: 'poll_votes_account_id_null', validate: false
    change_column_null :poll_votes, :account_id, true
  end
end
