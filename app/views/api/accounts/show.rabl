object @account

attributes :id, :username, :acct, :display_name, :note

node(:url)       { |account| url_for_target(account) }
node(:avatar)    { |account| asset_url(account.avatar.url(:large, false)) }
node(:followers) { |account| account.followers.count }
node(:following) { |account| account.following.count }
node(:statuses)  { |account| account.statuses.count  }
