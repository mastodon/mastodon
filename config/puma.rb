# frozen_string_literal: true

persistent_timeout ENV.fetch('PERSISTENT_TIMEOUT') { 20 }.to_i

max_threads_count = ENV.fetch('MAX_THREADS') { 5 }.to_i
min_threads_count = ENV.fetch('MIN_THREADS') { max_threads_count }.to_i
threads min_threads_count, max_threads_count

if ENV['SOCKET']
  bind "unix://#{ENV['SOCKET']}"
else
  bind "tcp://#{ENV.fetch('BIND', '127.0.0.1')}:#{ENV.fetch('PORT', 3000)}"
end

environment ENV.fetch('RAILS_ENV') { 'development' }
workers     ENV.fetch('WEB_CONCURRENCY') { 2 }.to_i

preload_app!

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end

plugin :tmp_restart

set_remote_address(proxy_protocol: :v1) if ENV['PROXY_PROTO_V1'] == 'true'
