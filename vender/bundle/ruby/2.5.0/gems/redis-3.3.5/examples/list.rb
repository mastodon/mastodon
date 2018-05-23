require 'rubygems'
require 'redis'

r = Redis.new

r.del 'logs'

puts

p "pushing log messages into a LIST"
r.rpush 'logs', 'some log message'
r.rpush 'logs', 'another log message'
r.rpush 'logs', 'yet another log message'
r.rpush 'logs', 'also another log message'

puts
p 'contents of logs LIST'

p r.lrange('logs', 0, -1)

puts
p 'Trim logs LIST to last 2 elements(easy circular buffer)'

r.ltrim('logs', -2, -1)

p r.lrange('logs', 0, -1)
