extends 'activitypub/types/person.rabl'

object @account

attributes display_name: :name, username: :preferredUsername, note: :summary

node(:icon)   { |account| full_asset_url(account.avatar.url(:original)) }
node(:image)  { |account| full_asset_url(account.header.url(:original)) }
