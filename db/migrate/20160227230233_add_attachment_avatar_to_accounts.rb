class AddAttachmentAvatarToAccounts < ActiveRecord::Migration
  def self.up
    change_table :accounts do |t|
      t.attachment :avatar
    end
  end

  def self.down
    remove_attachment :accounts, :avatar
  end
end
