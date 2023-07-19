# frozen_string_literal: true

class AddAttachmentAvatarToAccounts < ActiveRecord::Migration[4.2]
  def self.up
    change_table :accounts do |t|
      t.attachment :avatar
    end
  end

  def self.down
    remove_attachment :accounts, :avatar
  end
end
