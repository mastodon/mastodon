threads_count = ENV.fetch('MAX_THREADS') { 5 }.to_i
threads threads_count, threads_count

port        ENV.fetch('PORT') { 3000 }
environment ENV.fetch('RAILS_ENV') { 'development' }
workers     ENV.fetch('WEB_CONCURRENCY') { 2 }

preload_app!

on_worker_boot do
  if ENV['HEROKU'] # Spawn the workers from Puma, to only use one dyno
    @sidekiq_pid ||= spawn('bundle exec sidekiq -q default -q push -q pull -q mailers ')
  end

  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

plugin :tmp_restart
