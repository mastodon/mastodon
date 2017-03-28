object @account

attributes :id, :username, :acct, :display_name, :locked, :created_at

node(:note)            { |account| Formatter.instance.simplified_format(account) }
node(:url)             { |account| TagManager.instance.url_for(account) }
node(:avatar)          { |account| full_asset_url(account.avatar.url(:original)) }
node(:header)          { |account| full_asset_url(account.header.url(:original)) }
node(:followers_count) { |account| defined?(@followers_counts_map) ? (@followers_counts_map[account.id] || 0) : (account.try(:followers_count) || account.followers.count) }
node(:following_count) { |account| defined?(@following_counts_map) ? (@following_counts_map[account.id] || 0) : (account.try(:following_count) || account.following.count) }
node(:statuses_count)  { |account| defined?(@statuses_counts_map)  ? (@statuses_counts_map[account.id]  || 0) : (account.try(:statuses_count)  || account.statuses.count) }
