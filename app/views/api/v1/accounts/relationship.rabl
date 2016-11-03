object @account

attribute :id
node(:following)   { |account| @following[account.id]   || false }
node(:followed_by) { |account| @followed_by[account.id] || false }
node(:blocking)    { |account| @blocking[account.id]    || false }
