class DowncaseCustomEmojiDomains < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    CustomEmoji.in_batches.update_all('domain = lower(domain)')
  end
end
