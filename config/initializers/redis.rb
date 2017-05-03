# frozen_string_literal: true

Redis.current = Redis.new(
  host: ENV.fetch('REDIS_HOST') { 'localhost' },
  port: ENV.fetch('REDIS_PORT') { 6379 },
  password: ENV.fetch('REDIS_PASSWORD') { false },
  db: ENV.fetch('REDIS_DB') {0},
  driver: :hiredis
)
