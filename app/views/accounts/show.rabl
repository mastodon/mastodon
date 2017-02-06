extends 'activitypub/types/person.rabl'

object @account

node(:url)                { |account| TagManager.instance.url_for(account) }
node(:name)               { |account| account.display_name }
node(:preferredUsername)  { |account| account.username }
node(:summary)            { |account| account.note }
node(:icon)               { |account| full_asset_url(account.avatar.url(:original)) }
