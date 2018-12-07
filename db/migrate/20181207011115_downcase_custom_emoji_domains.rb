class DowncaseCustomEmojiDomains < ActiveRecord::Migration[5.2]
  def change
    CustomEmoji.update_all('domain = lower(domain)')
  end
end
