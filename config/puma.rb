threads_count = ENV.fetch('MAX_THREADS') { 5 }.to_i
threads threads_count, threads_count

if ENV['SOCKET'] then
  bind 'unix://' + ENV['SOCKET']
else
  port_num = ENV.fetch('PORT') { 3000 }
  bind "tcp://127.0.0.1:#{port_num}"
end

environment ENV.fetch('RAILS_ENV') { 'development' }
workers     ENV.fetch('WEB_CONCURRENCY') { 2 }

preload_app!

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

plugin :tmp_restart
