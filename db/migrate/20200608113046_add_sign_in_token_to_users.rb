# frozen_string_literal: true

class AddSignInTokenToUsers < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      change_table(:users, bulk: true) do |t|
        t.column :sign_in_token, :string
        t.column :sign_in_token_sent_at, :datetime
      end
    end
  end
end
