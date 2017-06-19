
node(:type) { 'Mention' }
node(:href) { |account| ActivityPub::TagManager.instance.uri_for(account) }
node(:name) { |account| "@#{account.username}" }
