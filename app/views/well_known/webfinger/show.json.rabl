object @account

node(:subject) { @canonical_account_uri }

node(:aliases) do
  [TagManager.instance.url_for(@account)]
end

node(:links) do
  [
    { rel: 'http://webfinger.net/rel/profile-page', type: 'text/html', href: TagManager.instance.url_for(@account) },
    { rel: 'http://schemas.google.com/g/2010#updates-from', type: 'application/atom+xml', href: account_url(@account, format: 'atom') },
    { rel: 'salmon', href: api_salmon_url(@account.id) },
    { rel: 'magic-public-key', href: "data:application/magic-public-key,#{@magic_key}" },
    { rel: 'http://ostatus.org/schema/1.0/subscribe', template: "#{authorize_follow_url}?acct={uri}" },
  ]
end
