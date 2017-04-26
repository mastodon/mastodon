require 'sidekiq'
require 'sidekiq/scheduler'

Sidekiq.configure_server do |config|
  config.on(:startup) do
    Sidekiq.schedule = YAML.safe_load(File.read("#{Rails.root}/config/sidekiq_scheduler.yml"))
    Sidekiq::Scheduler.reload_schedule!
  end
end
