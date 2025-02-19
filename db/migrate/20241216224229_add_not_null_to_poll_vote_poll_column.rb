# frozen_string_literal: true

class AddNotNullToPollVotePollColumn < ActiveRecord::Migration[7.2]
  def change
    add_check_constraint :poll_votes, 'poll_id IS NOT NULL', name: 'poll_votes_poll_id_null', validate: false
  end
end
