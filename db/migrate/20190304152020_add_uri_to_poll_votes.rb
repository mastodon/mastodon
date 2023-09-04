class AddUriToPollVotes < ActiveRecord::Migration[5.2]
  def change
    add_column :poll_votes, :uri, :string
  end
end
