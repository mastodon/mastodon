require 'sidekiq/web' unless defined?(Sidekiq::Web)

Sidekiq::Web.register(SidekiqScheduler::Web)
Sidekiq::Web.tabs['recurring_jobs'] = 'recurring-jobs'
Sidekiq::Web.locales << File.expand_path(File.dirname(__FILE__) + '/../../../web/locales')
