# frozen_string_literal: true

class AddAgeVerifiedAtToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :age_verified_at, :datetime
  end
end
