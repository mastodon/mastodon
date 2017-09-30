class AddAttachmentHeaderToAccounts < ActiveRecord::Migration[4.2]
  def self.up
    change_table :accounts do |t|
      t.attachment :header
    end
  end

  def self.down
    remove_attachment :accounts, :header
  end
end
