object @account

attribute :id
node(:following)       { |account| @relationship_map.following[account.id] || false }
node(:followed_by)     { |account| @relationship_map.followed_by[account.id] || false }
node(:blocking)        { |account| @relationship_map.blocking[account.id] || false }
node(:muting)          { |account| @relationship_map.muting[account.id] || false }
node(:requested)       { |account| @relationship_map.requested[account.id] || false }
node(:domain_blocking) { |account| @relationship_map.domain_blocking[account.id] || false }
