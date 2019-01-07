class DowncaseCustomEmojiDomains < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    duplicates = CustomEmoji.connection.select_all('SELECT string_agg(id::text, \',\') AS ids FROM custom_emojis GROUP BY shortcode, lower(domain) HAVING count(*) > 1').to_hash

    duplicates.each do |row|
      CustomEmoji.where(id: row['ids'].split(',')[0...-1]).destroy_all
    end

    CustomEmoji.in_batches.update_all('domain = lower(domain)')
  end

  def down; end
end
