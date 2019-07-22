web: if [ "$RUN_STREAMING" != "true" ]; then BIND=0.0.0.0 bundle exec puma -C config/puma.rb; else BIND=0.0.0.0 node ./streaming; fi
worker: bundle exec sidekiq

# For the streaming API, you need a separate app that shares Postgres and Redis:
#
# heroku create
# heroku buildpacks:add heroku/nodejs
# heroku config:set RUN_STREAMING=true
# heroku addons:attach <main-app>::DATABASE
# heroku addons:attach <main-app>::REDIS
#
# and let the main app use the separate app:
#
# heroku config:set STREAMING_API_BASE_URL=wss://<streaming-app>.herokuapp.com -a <main-app>
