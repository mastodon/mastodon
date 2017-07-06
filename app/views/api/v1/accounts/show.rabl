object @account

attributes :id, :username, :acct, :display_name, :locked, :created_at

node(:note) do |account|
    @plain_text_note ?
        Formatter.instance.simplified_plain_text_format(account) :
        Formatter.instance.simplified_format(account)
end
node(:url)             { |account| TagManager.instance.url_for(account) }
node(:avatar)          { |account| full_asset_url(account.avatar_original_url) }
node(:avatar_static)   { |account| full_asset_url(account.avatar_static_url) }
node(:header)          { |account| full_asset_url(account.header_original_url) }
node(:header_static)   { |account| full_asset_url(account.header_static_url) }

attributes :followers_count, :following_count, :statuses_count
