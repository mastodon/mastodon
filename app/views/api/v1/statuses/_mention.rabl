node(:url)  { |mention| TagManager.instance.url_for(mention.account) }
node(:acct) { |mention| mention.account.acct }
node(:id)   { |mention| mention.account_id }
