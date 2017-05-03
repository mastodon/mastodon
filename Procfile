web: puma -C config/puma.rb
worker: sidekiq -q default -q push -q pull -q mailers
release: rake db:migrate
