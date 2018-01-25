# frozen_string_literal: true

frontend_domain = ENV.fetch('FRONTEND_DOMAIN') { '127.0.0.1' }
websocket_scheme = ENV['LOCAL_HTTPS'] == 'true' ? 'wss://' : 'ws://'

ENV['STREAMING_API_BASE_URL'] = websocket_scheme + frontend_domain
exec(*ARGV)
