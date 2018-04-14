# Run with
#
#   $ ruby -Ilib benchmarking/logging.rb
#

begin
  require "bench"
rescue LoadError
  $stderr.puts "`gem install bench` and try again."
  exit 1
end

require "redis"
require "logger"

def log(level, namespace = nil)
  logger = (namespace || Kernel).const_get(:Logger).new("/dev/null")
  logger.level = (namespace || Logger).const_get(level)
  logger
end

def stress(redis)
  redis.flushdb

  n = (ARGV.shift || 2000).to_i

  n.times do |i|
    key = "foo:#{i}"
    redis.set key, i
    redis.get key
  end
end

default = Redis.new

logging_redises = [
  Redis.new(:logger => log(:DEBUG)),
  Redis.new(:logger => log(:INFO)),
]

begin
  require "log4r"

  logging_redises += [
    Redis.new(:logger => log(:DEBUG, Log4r)),
    Redis.new(:logger => log(:INFO, Log4r)),
  ]
rescue LoadError
  $stderr.puts "Log4r not installed. `gem install log4r` if you want to compare it against Ruby's Logger (spoiler: it's much faster)."
end

benchmark "Default options (no logger)" do
  stress(default)
end

logging_redises.each do |redis|
  logger = redis.client.logger

  case logger
  when Logger
    level = Logger::SEV_LABEL[logger.level]
  when Log4r::Logger
    level = logger.levels[logger.level]
  end

  benchmark "#{logger.class} on #{level}" do
    stress(redis)
  end
end

run 10
