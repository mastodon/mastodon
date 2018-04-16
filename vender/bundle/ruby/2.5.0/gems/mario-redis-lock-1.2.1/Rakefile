require "bundler/gem_tasks"
require "rake/testtask"
require "redis_lock"

Rake::TestTask.new do |t|
  t.pattern = "spec/**/*_spec.rb"
end

desc 'Flush the test database (15)'
task :flushdb do
  redis_test_db.flushdb
end

desc 'Test app: The lock is the joint, only one thread can smoke at a time'
task :smoke_and_pass do
  threads = (ENV['threads'] || 6).to_i
  puts "The big smoke starts with #{threads} threads"
  puts "Use ctr+c to EXIT"

  RedisLock.configure do |conf|
    conf.redis = redis_test_db
    conf.key = 'the_joint'
    conf.autorelease = 0.6
    conf.retry_timeout = 0.5
    conf.retry_sleep = 0.1
  end

  ts = []
  threads.times do |i|
    ts << Thread.new do
      smoker(i)
    end
  end

  ts.each do |t|
    t.join
  end
end

def smoker(id)
  loop do
    color_puts id, "         Thread##{id} wants to smoke"
    lock = RedisLock.new
    if lock.acquire
      color_puts id, "joint >> Thread##{id} grabs the joint from the table"
      sleep (rand < 0.5 ? 0.3 : 0.4) # SMOKE for 0.3 or 0.4 seconds
      if rand < 0.1
        color_puts id, "CRASH!!! Thread##{id} DIED while smoking. The joint will come back to the table when autoreleased"
        break
      else
        color_puts id, "      << Thread##{id} returs the joint to the table\n"
        lock.release
      end

    else
      color_puts id, "      !! Thread##{id} could not get the joint. Try again later"
    end

    sleep 0.3 + rand(4).to_f/10 # WAIT for next try
  end
end

# Wrap text with ANSI colors
def color_puts(id, text)
  if id < 10
    print "\033[0;3#{id+1}m#{text}\033[0m\n"
  else
    print "#{text}\n"
  end
end

def redis_test_db
  require 'redis'
  @redis_test_db ||= Redis.new(db: 15)
end
