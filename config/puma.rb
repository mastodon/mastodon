threads_count = ENV.fetch('MAX_THREADS') { 5 }.to_i
threads threads_count, threads_count
application_path = "#{File.expand_path("../..", __FILE__)}"

if ENV['SOCKET'] then
  bind 'unix://' + ENV['SOCKET']
else
  port ENV.fetch('PORT') { 3000 }
end

environment ENV.fetch('RAILS_ENV') { 'development' }
workers     ENV.fetch('WEB_CONCURRENCY') { 2 }

preload_app!

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

stdout_redirect "#{application_path}/log/stdout", "#{application_path}/log/stderr", true

plugin :tmp_restart
