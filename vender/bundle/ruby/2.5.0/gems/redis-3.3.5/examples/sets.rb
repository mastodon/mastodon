require 'rubygems'
require 'redis'

r = Redis.new

r.del 'foo-tags'
r.del 'bar-tags'

puts
p "create a set of tags on foo-tags"

r.sadd 'foo-tags', 'one'
r.sadd 'foo-tags', 'two'
r.sadd 'foo-tags', 'three'

puts
p "create a set of tags on bar-tags"

r.sadd 'bar-tags', 'three'
r.sadd 'bar-tags', 'four'
r.sadd 'bar-tags', 'five'

puts
p 'foo-tags'

p r.smembers('foo-tags')

puts
p 'bar-tags'

p r.smembers('bar-tags')

puts
p 'intersection of foo-tags and bar-tags'

p r.sinter('foo-tags', 'bar-tags')
