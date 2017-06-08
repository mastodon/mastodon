object @account

attribute :id
node(:following)       { |account| @following[account.id]       || false }
node(:followed_by)     { |account| @followed_by[account.id]     || false }
node(:blocking)        { |account| @blocking[account.id]        || false }
node(:muting)          { |account| @muting[account.id]          || false }
node(:requested)       { |account| @requested[account.id]       || false }
node(:domain_blocking) { |account| @domain_blocking[account.id] || false }
