require "rake/testtask"

ENV["REDIS_BRANCH"] ||= "unstable"

REDIS_DIR = File.expand_path(File.join("..", "test"), __FILE__)
REDIS_CNF = File.join(REDIS_DIR, "test.conf")
REDIS_CNF_TEMPLATE = File.join(REDIS_DIR, "test.conf.erb")
REDIS_PID = File.join(REDIS_DIR, "db", "redis.pid")
REDIS_LOG = File.join(REDIS_DIR, "db", "redis.log")
REDIS_SOCKET = File.join(REDIS_DIR, "db", "redis.sock")
BINARY = "tmp/redis-#{ENV["REDIS_BRANCH"]}/src/redis-server"

task :default => :run

desc "Run tests and manage server start/stop"
task :run => [:start, :test, :stop]

desc "Start the Redis server"
task :start => [BINARY, REDIS_CNF] do
  sh "#{BINARY} --version"

  redis_running = \
  begin
    File.exists?(REDIS_PID) && Process.kill(0, File.read(REDIS_PID).to_i)
  rescue Errno::ESRCH
    FileUtils.rm REDIS_PID
    false
  end

  unless redis_running
    unless system("#{BINARY} #{REDIS_CNF}")
      abort "could not start redis-server"
    end
  end

  at_exit do
    Rake::Task["stop"].invoke
  end
end

desc "Stop the Redis server"
task :stop do
  if File.exists?(REDIS_PID)
    Process.kill "INT", File.read(REDIS_PID).to_i
    FileUtils.rm REDIS_PID
  end
end

desc "Clean up testing artifacts"
task :clean do
  FileUtils.rm_f(BINARY)
  FileUtils.rm_f(REDIS_CNF)
end

file BINARY do
  branch = ENV.fetch("REDIS_BRANCH")

  sh <<-SH
  mkdir -p tmp;
  cd tmp;
  rm -rf redis-#{branch};
  wget https://github.com/antirez/redis/archive/#{branch}.tar.gz -O #{branch}.tar.gz;
  tar xf #{branch}.tar.gz;
  cd redis-#{branch};
  make
  SH
end

file REDIS_CNF => [REDIS_CNF_TEMPLATE, __FILE__] do |t|
  require 'erb'

  erb = t.prerequisites[0]
  template = File.read(erb)

  File.open(REDIS_CNF, 'w') do |file|
    file.puts "\# This file was auto-generated at #{Time.now}",
              "\# from (#{erb})",
              "\#"
    conf = ERB.new(template).result
    file << conf
  end
end

Rake::TestTask.new do |t|
  t.options = "-v" if $VERBOSE
  t.test_files = FileList["test/*_test.rb"]
end
