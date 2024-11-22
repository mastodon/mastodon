# frozen_string_literal: true

Account.create_with(actor_type: 'Application', locked: true, username: 'mastodon.internal').find_or_create_by(id: Account::INSTANCE_ACTOR_ID)
