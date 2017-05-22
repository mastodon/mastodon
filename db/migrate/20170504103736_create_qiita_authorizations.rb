class CreateQiitaAuthorizations < ActiveRecord::Migration[5.0]
  def change
    create_table :qiita_authorizations do |t|
      t.belongs_to :user, foreign_key: true
      t.string :uid
      t.string :token

      t.index :uid, unique: true
      t.timestamps
    end
  end
end
