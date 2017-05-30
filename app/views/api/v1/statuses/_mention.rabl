node(:url)      { |mention| TagManager.instance.url_for(mention.account) }
node(:acct)     { |mention| mention.account_acct }
node(:id)       { |mention| mention.account_id }
node(:username) { |mention| mention.account_username }
