# frozen_string_literal: true

class AddSkipSignInTokenToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :skip_sign_in_token, :boolean
  end
end
