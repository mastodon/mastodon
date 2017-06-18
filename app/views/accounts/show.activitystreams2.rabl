object @account

node(:'@context') { 'https://www.w3.org/ns/activitystreams' }
node(:id) { |account| account_url(account) }
node(:type) { 'Person' }
node(:outbox) { |account| api_activitypub_outbox_url(account.id) }
node(:inbox) { nil }
node(:preferredUsername, &:username)
node(:name, if: :display_name?, &:display_name)
node(:summary, if: :note?) { |account| Formatter.instance.simplified_format(account) }
node(:icon, if: :avatar?) { |account| full_asset_url(account.avatar.url(:original)) }
node(:image, if: :header?) { |account| full_asset_url(account.header.url(:original)) }
