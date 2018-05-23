require 'sidekiq'
require_relative '../schedule'

Sidekiq.extend SidekiqScheduler::Schedule
