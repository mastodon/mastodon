class CreateMediaTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :media_tokens do |t|
      t.bigint :media_attachment_id

      t.timestamps
    end
  end
end
