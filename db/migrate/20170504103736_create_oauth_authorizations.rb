class CreateOauthAuthorizations < ActiveRecord::Migration[5.0]
  def change
    create_table :oauth_authorizations do |t|
      t.belongs_to :user, foreign_key: true
      t.string :provider
      t.string :uid

      t.index [:provider, :uid]
      t.timestamps
    end
  end
end
