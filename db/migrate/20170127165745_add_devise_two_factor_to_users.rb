# frozen_string_literal: true

class AddDeviseTwoFactorToUsers < ActiveRecord::Migration[5.0]
  def change
    change_table(:users, bulk: true) do |t|
      t.column :encrypted_otp_secret, :string
      t.column :encrypted_otp_secret_iv, :string
      t.column :encrypted_otp_secret_salt, :string
      t.column :consumed_timestep, :integer
      t.column :otp_required_for_login, :boolean # rubocop:disable Rails/ThreeStateBooleanColumn
    end
  end
end
