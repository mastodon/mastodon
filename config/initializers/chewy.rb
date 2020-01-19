enabled         = ENV['ES_ENABLED'] == 'true'
host            = ENV.fetch('ES_HOST') { 'localhost' }
port            = ENV.fetch('ES_PORT') { 9200 }
user		= ENV.fetch('ES_USER') {''}
pass		= ENV.fetch('ES_PASS') {''}
ssl		= ENV.fetch('ES_SSL') {'false'}
fallback_prefix = ENV.fetch('REDIS_NAMESPACE') { nil }
prefix          = ENV.fetch('ES_PREFIX') { fallback_prefix }

if (user == "")  or (pass == "") then
  Chewy.settings = {
    host: "#{host}:#{port}",
    prefix: prefix,
    enabled: enabled,
    journal: false,
    sidekiq: { queue: 'pull' },
  }

  Chewy.root_strategy    = enabled ? :sidekiq : :bypass
  Chewy.request_strategy = enabled ? :sidekiq : :bypass
  Chewy.use_after_commit_callbacks = false

  module Chewy
    class << self
      def enabled?
        settings[:enabled]
      end
    end
  end
else

  Chewy.settings = {
    host: "https://#{host}:#{port}",
    user: user,
    password: pass,
    prefix: prefix,
    enabled: enabled,
    journal: false,
    sidekiq: { queue: 'pull' },
  }
  Chewy.root_strategy    = enabled ? :sidekiq : :bypass
  Chewy.request_strategy = enabled ? :sidekiq : :bypass
  Chewy.use_after_commit_callbacks = false   

  module Chewy
    class << self
      def enabled?
	settings[:enabled]
      end
    end
  end
end
