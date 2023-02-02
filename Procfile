web: bundle exec foreman start -f heroku/Procfile.web
worker: bundle exec sidekiq
release: SKIP_POST_DEPLOYMENT_MIGRATIONS=true bundle exec rails db:migrate
