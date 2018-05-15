class AddAccessTokenIdToWebPushSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_reference :web_push_subscriptions, :access_token, null: true, default: nil, foreign_key: { on_delete: :cascade, to_table: :oauth_access_tokens }, index: false
    add_reference :web_push_subscriptions, :user, null: true, default: nil, foreign_key: { on_delete: :cascade }, index: false
  end
end
