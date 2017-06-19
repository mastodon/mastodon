
node(:type) { 'Mention' }
node(:href) { |account| ActivityPub::TagManager.uri_for(account) }
node(:name) { |account| "@#{account.username}" }
