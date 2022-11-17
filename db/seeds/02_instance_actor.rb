Account.create_with(actor_type: 'Application', locked: true, username: ENV['LOCAL_DOMAIN'] || Rails.configuration.x.local_domain).find_or_create_by(id: -99)
