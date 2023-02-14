Account.create_with(actor_type: 'Application', locked: true, username: 'mastodon.internal').find_or_create_by(id: -99)
