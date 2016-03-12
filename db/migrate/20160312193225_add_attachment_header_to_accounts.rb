class AddAttachmentHeaderToAccounts < ActiveRecord::Migration
  def self.up
    change_table :accounts do |t|
      t.attachment :header
    end
  end

  def self.down
    remove_attachment :accounts, :header
  end
end
