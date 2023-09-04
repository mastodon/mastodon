# frozen_string_literal: true

class AddIndexIpBlocksOnIp < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    duplicates = IpBlock.connection.select_all('SELECT string_agg(id::text, \',\') AS ids FROM ip_blocks GROUP BY ip HAVING count(*) > 1').to_ary

    duplicates.each do |row|
      IpBlock.where(id: row['ids'].split(',')[0...-1]).destroy_all
    end

    add_index :ip_blocks, :ip, unique: true, algorithm: :concurrently
  end

  def down
    remove_index :ip_blocks, :ip, unique: true
  end
end
