# frozen_string_literal: true

class AddOtpSecretToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :otp_secret, :string
  end
end
